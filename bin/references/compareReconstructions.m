%% 
function compareReconstructions()

%coordOffsetForDt=[658 7186 146];    % cell 5
coordOffsetForDt=[1298 274 402];    % cell 6
hdf5expert='/omelette/2/jk/omniweb/reconstruction/osgc003d.h5';

dbDumpTasks='/omelette/2/jk/omniweb/validation/dbDump_cell6/tasks';
dbDumpVolumes='/omelette/2/jk/omniweb/validation/dbDump_cell6/volumes';
dbDumpValidations='/omelette/2/jk/omniweb/validation/dbDump_cell6/validations';
homeVolumes='/omelette/2/omniweb_data';

addpath /omelette/2/jk/omniweb/bin
addpath /omelette/2/jk/omniweb/bin/mysql
addpath /omelette/2/jk/e2198/bin/hdf5

addpath './mysql/'

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

[account_id account_username]=mysql('select id,username from accounts');
[volume_id volume_path]=mysql('select id,path from volumes');
[task_id task_seeds task_volumeid]=mysql('select id,seeds,channel_id from tasks where cell=6 and status=0');

fo=fopen('accuracy.txt','w');
f1=fopen('truth.txt','w');
f2=fopen('duplicate.txt','w');
f3=fopen('task.txt','w');

history=cell(numel(task_id),1);

for j=1:numel(task_id)

    volPathInDB=volume_path{find(volume_id==task_volumeid(j),1)};
    pos=strfind(volPathInDB,'/');
    volPath=sprintf('%s/%s',homeVolumes,volPathInDB(pos(6)+1:pos(9)-1));
    rtn=textscan(volPathInDB(pos(8)+1:pos(9)-1),'x%dy%dz%d_s%d_%d_%d_e%d_%d_%d');
    st=double([rtn{4} rtn{5} rtn{6}]);
    off=floor(((st-1)-coordOffsetForDt)/mipFactor);
    volExpert=get_hdf5_file(hdf5expert,'/main',off+1,off+sizeVolume);
    volExpert=logical(volExpert);   % include all the tasks in this volume
    
    vol=getVolumeSegmentation([volPath segRawPostfix]); % volume raw segmentation
    segSeeds=convSegSql(task_seeds{j},0);
    seed=ismember(vol,segSeeds);
    sizeSeed=sum(sum(sum(seed)));
    
    % extract validation for this task, among all the validations in the volume
    cc=bwconncomp(volExpert,26);
    b=false;
    for i=1:cc.NumObjects    
        volExpertTask=false(sizeVolume);
        volExpertTask(cc.PixelIdxList{i})=1;
        
        overlap=sum(sum(sum(volExpertTask.*seed)));
        if (overlap>sizeSeed*0.9)
            b=true;
            break;
        end
    end
    if (b)
    else
    end
    truth=setdiff(vol(volExpertTask),0);
    t=sum(sum(sum(volExpertTask)));
    
    % exclude false segments (wrongly detected due to mismatch)
    overlap=arrayfun(@(x) sum(vol(volExpertTask)==x),truth);
    sizeSegment=arrayfun(@(x) sum(sum(sum(vol==x))),truth);
    bExclude=(overlap./sizeSegment)<0.9;
    truth(bExclude)=[];
    
    % check duplication
    for i=1:j-1
        if (strcmp(history{i}{1},volPath) && all(ismember(truth,history{i}{3})))
            fprintf(f2,'%d %d %s\n',task_id(j),history{i}{2},volPath);
            fprintf('>> duplication: %d %d %s\n',task_id(j),history{i}{2},volPath);
        end
    end
    history{j}={volPath task_id(j) truth};
    
    % print out ground truth info
    fprintf(f1,'% 6d: ',task_id(j));
    fprintf(f1,'%d ',truth);
    fprintf(f1,'\n');

    % compute the accuracy for user validations
    %query=sprintf('select user_id,segments,date(finish),time(finish) from validations where (status=0 or status=1) and task_id=%d',task_id(j));
    query=sprintf('select user_id,segments,date(start),time(start) from validations where status=9 and task_id=%d',task_id(j));
    [validation_userid validation_segments validation_finishdate validation_finishtime]=mysql(query);    
    
    fnegavg=0;
    fposavg=0;
    N=numel(validation_userid);
    for i=1:N
        segValid=convSegSql(validation_segments{i},0);
        volValid=ismember(vol,segValid);

        fneg=sum(sum(sum(~volValid.*volExpertTask)));
        fpos=sum(sum(sum(volValid.*~volExpertTask)));
        fnegavg=fnegavg+fneg;
        fposavg=fposavg+fpos;
        
        %username=account_username{find(account_id==validation_userid(i),1)};
        username='consensus';
        fprintf(fo,'% 6d % 16s %.1f%% %.1f%% %d %s %s\n',task_id(j),username,fneg/t*100,fpos/t*100,t,datestr(validation_finishdate(i),'yyyy-mm-dd'),datestr(validation_finishtime(i),'HH:MM:SS'));
        fprintf('% 6d % 16s %.1f%% %.1f%% %d %s %s\n',task_id(j),username,fneg/t*100,fpos/t*100,t,datestr(validation_finishdate(i),'yyyy-mm-dd'),datestr(validation_finishtime(i),'HH:MM:SS'));
    end
    fprintf(f3,'%d %d %.1f %.1f\n',task_id(j),t,fnegavg/N/t*100,fposavg/N/t*100);
    fprintf('>> % 6d %d %.1f %.1f\n',task_id(j),t,fnegavg/N/t*100,fposavg/N/t*100);
end

fclose(fo);
fclose(f1);
fclose(f2);

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
