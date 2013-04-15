%% 
function compareReconstructions2()

%coordOffsetForDt=[658 7186 146];    % cell 5
coordOffsetForDt=[1298 274 402];    % cell 6
hdf5expert='/omelette/1/omniweb_data/reconstruction/osgc003d.h5';

homeVolumes='/omelette/2/omniweb_data';

addpath /omelette/2/jk/omniweb/bin
addpath /omelette/2/jk/omniweb/bin/mysql
addpath /omelette/2/jk/e2198/bin/hdf5

mipLevel=1;
mipFactor=2^mipLevel;
segRawPostfix=['/segmentations/segmentation1/' num2str(mipLevel) '/volume.uint32_t.raw'];

global sizeofUint32 sizeChunkLinear sizeChunk sizeVolume
sizeChunk=[128 128 128];
sizeVolume=[128 128 128];
sizeChunkLinear=prod(sizeChunk);
sizeofUint32=4;

mysql('open','127.0.0.1:13306','omnidev','we8pizza');
mysql('use omniweb');

fi=fopen('truth.txt','r');
tline=fgetl(fi);
cnt=0;
while ischar(tline)
    cnt=cnt+1;
    pos=strfind(tline,' ');
    task_id(cnt)=str2double(tline(pos(1)+1:pos(2)-1));
    task_truth{cnt}=[];
    for i=2:numel(pos)-1
        task_truth{cnt}=[task_truth{cnt}; str2double(tline(pos(i)+1:pos(i+1)-1))];
    end
    tline=fgetl(fi);
end
fclose(fi);

fi=fopen('listexclude.txt','r');
listexclude=fscanf(fi,'%d\n',inf);
fclose(fi);

fo=fopen('segincprob.txt','w');

for j=1:numel(task_id)

    if ismember(task_id(j),listexclude)
        continue;
    end

    fprintf('* task: %d\n',task_id(j));
    
    % to exclude seeds from truth
    query=sprintf('select seeds from tasks where id=%d',task_id(j));
    [task_seedstring]=mysql(query);    
    task_seeds=convSegSql(task_seedstring{1},0);
    truth=setdiff(task_truth{j},task_seeds);
    %
    
    query=sprintf('select user_id,segments from validations where (status=0 or status=1) and task_id=%d',task_id(j));
    [validation_userid validation_segstring]=mysql(query);    
    validation_segments=cellfun(@(x) convSegSql(x,0),validation_segstring,'UniformOutput',false);
    allSegsInValidation=setdiff([validation_segments{:}]',task_seeds);

    % volume raw segmentation
    fprintf('  >> reading volume\n');
    query=sprintf('select path from volumes where id=(select channel_id from tasks where id=%d)',task_id(j));
    rtn=mysql(query);    
    volPathInDB=rtn{1};
    pos=strfind(volPathInDB,'/');
    volPath=sprintf('%s/%s',homeVolumes,volPathInDB(pos(6)+1:pos(9)-1));    
    vol=getVolumeSegmentation([volPath segRawPostfix]); 

    % size of segments
    size_seeds=sum(ismember(vol(:),task_seeds));
    sizeSegsInValidation=arrayfun(@(x) sum(ismember(vol(:),x)),allSegsInValidation);

    % result:
    Lthr=[0.001 0.002 0.005 0.01 0.02 0.05];
    thr=Lthr(5);
    
    filtSegsInValidation=allSegsInValidation(sizeSegsInValidation>thr*size_seeds);
    appear=arrayfun(@(y) sum(cellfun(@(x) ismember(y,x),validation_segments)), filtSegsInValidation);
    appear=appear/numel(validation_segments);    

    fprintf('%f\n',appear);
    fprintf(fo,'%f\n',appear);
end

fclose(fo);

mysql('close');

end

%%
function [vol]=getVolumeSegmentation(fn)

global sizeofUint32 sizeChunk sizeChunkLinear sizeVolume

sizeVolumeInChunks=sizeVolume./sizeChunk;
vol=zeros(sizeVolume,'uint32');

fp=fopen(fn,'r');
for x=1:sizeVolumeInChunks(1)
    for y=1:sizeVolumeInChunks(2)
        for z=1:sizeVolumeInChunks(3)
            sub=[x y z];
            indChunk=sub2ind(sizeVolumeInChunks,sub(1),sub(2),sub(3));
            offset=(sizeofUint32*(indChunk-1)*sizeChunkLinear);
            fseek(fp,offset,'bof');
            chunk=reshape(fread(fp,sizeChunkLinear,'*uint32'),sizeChunk);
            st=([x y z]-1).*sizeChunk+1;
            ed=([x y z]).*sizeChunk;
            vol(st(1):ed(1),st(2):ed(2),st(3):ed(3))=chunk;
        end
    end
end
fclose(fp);

end
