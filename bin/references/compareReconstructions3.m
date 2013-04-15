%% 
function compareReconstructions3()

homeVolumes='/omelette/2/omniweb_data';

addpath /omelette/2/jk/omniweb/bin
addpath /omelette/2/jk/omniweb/bin/mysql
addpath /omelette/2/jk/e2198/bin/hdf5

mipLevel=1;
mipFactor=2^mipLevel;
segRawPostfix=['/segmentations/segmentation1/' num2str(mipLevel) '/volume.uint32_t.raw'];

global sizeofUint32 sizeChunkLinear sizeChunk sizeVolume
sizeChunk=[128 128 128];
sizeVolume=[256 256 256]/mipFactor;
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
    task_truth{cnt,1}=[];
    for i=2:numel(pos)-1
        task_truth{cnt,1}=[task_truth{cnt,1}; str2double(tline(pos(i)+1:pos(i+1)-1))];
    end
    tline=fgetl(fi);
end
fclose(fi);

listexclude=cellfun(@(x) str2double(x),readTextFileIntoCellArray('listexclude.txt'));

% f1=fopen('disagreement_size.txt','w');
% f2=fopen('disagreement_numseg.txt','w');
% f3=fopen('disagreement_frac2seeds.txt','w');
% f4=fopen('disagreement_numObjects.txt','w');

Lthr=[0.001 0.005 0.01 0.02];
for thr=Lthr

    filename=sprintf('disagreement_num2truth.thr%02d',thr*1000);
    fo=fopen(filename,'w');

    for j=1:numel(task_id)

        if ismember(task_id(j),listexclude)
            continue;
        end

        fprintf('* task: %d\n',task_id(j));
        fprintf(fo,'%04d ',task_id(j));
        truth_all=task_truth{j};

        % to exclude seeds from truth
        query=sprintf('select seeds from tasks where id=%d',task_id(j));
        [task_seedstring]=mysql(query);    
        task_seeds=convSegSql(task_seedstring{1},0);

        % validations by users
        query=sprintf('select user_id,segments from validations where (status=0 or status=1) and task_id=%d and user_id<>0',task_id(j));
        [validation_userid validation_segstring]=mysql(query);    
        validation_segments=cellfun(@(x) convSegSql(x,0),validation_segstring,'UniformOutput',false);
        union_all=unique([validation_segments{:}])';

        appear=arrayfun(@(y) sum(cellfun(@(x) ismember(y,x),validation_segments)), union_all);
        consensus_all=union_all(appear==numel(validation_segments));
        disagreement=setdiff(union_all,consensus_all);

        % read volume raw segmentation
        query=sprintf('select path from volumes where id=(select channel_id from tasks where id=%d)',task_id(j));
        rtn=mysql(query);    
        volPathInDB=rtn{1};
        pos=strfind(volPathInDB,'/');
        volPath=sprintf('%s/%s',homeVolumes,volPathInDB(pos(6)+1:pos(9)-1));    
        vol=getVolumeSegmentation([volPath segRawPostfix]);

        size_truth_all=sum(ismember(vol(:),truth_all));
        size_seeds=sum(ismember(vol(:),task_seeds));

        % false negative/positive of the consensus
        seg_fn=setdiff(truth_all,consensus_all);
        seg_fp=setdiff(consensus_all,truth_all);
        fn=sum(ismember(vol(:),seg_fn))/size_truth_all;
        fp=sum(ismember(vol(:),seg_fp))/size_truth_all;
        fprintf(fo,'%f %f ',fn,fp);    
        fprintf('  : %f %f ',fn,fp);    

        % false negative/positive of the union
        seg_fn=setdiff(truth_all,union_all);
        seg_fp=setdiff(union_all,truth_all);
        fn=sum(ismember(vol(:),seg_fn))/size_truth_all;
        fp=sum(ismember(vol(:),seg_fp))/size_truth_all;
        fprintf(fo,'%f %f ',fn,fp);    
        fprintf('%f %f ',fn,fp);    
        
        % cc of disagreement
        volBWDisagreement=ismember(vol,disagreement);
        CC=bwconncomp(volBWDisagreement);

        listSizeObject=cellfun(@(x) numel(x),CC.PixelIdxList)';
        segmentsInEachObject=cellfun(@(x) unique(vol(x)),CC.PixelIdxList,'UniformOutput',false)';

        smallSegs=[];
        for i=1:numel(listSizeObject)
            if (listSizeObject(i)<thr*size_seeds)
                smallSegs=[smallSegs; segmentsInEachObject{i}];
            end
        end
        segmentsInEachObject(listSizeObject<thr*size_seeds)=[];

        truth_woseed=setdiff(truth_all,task_seeds);
        truth_remain=setdiff(truth_woseed,consensus_all);
        truth_remain=setdiff(truth_remain,smallSegs);

        n=0; r=0;
        for i=1:numel(segmentsInEachObject)
            inObject=segmentsInEachObject{i};
            common=intersect(truth_remain,inObject);
            truth_remain=setdiff(truth_remain,common);

            if ~isempty(common) 
                object_remain=setdiff(inObject,common);
                if (~isempty(object_remain) && sum(ismember(vol(:),object_remain))>thr*size_seeds)
                    r=r+1;
                else
                    n=n+1;
                end
            end
        end

        % maximum completeness that can be reached by collecting the CCs
        size_reconstructed=1-sum(ismember(vol(:),truth_remain))/size_truth_all;
        fprintf(fo,'%f %d %d\n',size_reconstructed,n,r);
        fprintf('%f %d %d\n',size_reconstructed,n,r);
    end
    fclose(fo);
end

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
