%% 
% webtasks_getTruth('/data/omniData/e2198_reconstruction/jamb_sac.h5',70014,10);
function webtasks_getTruth(hdf5expert,segID,cellID,taskID)

mipLevel=1;
mipFactor=2^mipLevel;
segRawPostfix=['/segmentations/segmentation1/' num2str(mipLevel) '/volume.uint32_t.raw'];

homeVolumes='/omelette/2/omniweb_data';

addpath /omelette/2/jk/omniweb/bin
addpath /omelette/2/jk/omniweb/bin/mysql
addpath /omelette/2/jk/e2198/bin/hdf5

global sizeofUint32 sizeChunkLinear sizeChunk sizeVolume
sizeChunk=[128 128 128];
sizeVolume=[256 256 256]/mipFactor;
sizeChunkLinear=prod(sizeChunk);
sizeofUint32=4;

mysql('open','127.0.0.1:13306','omnidev','we8pizza');
mysql('use omniweb');

if exist('taskID','var')
    query=sprintf('select tasks.id,tasks.seeds,volumes.path from tasks join volumes where tasks.id=%d and tasks.cell=%d and tasks.status=0 and tasks.channel_id=volumes.id',taskID,cellID);
else
    query=sprintf('select tasks.id,tasks.seeds,volumes.path from tasks join volumes where tasks.cell=%d and tasks.status=0 and tasks.channel_id=volumes.id',cellID);
end
[taskID seeds volumePath]=mysql(query);
mysql('close');

for j=1:numel(taskID)

    pos=strfind(volumePath{j},'/');
    volName=volumePath{j}(pos(end-3)+1:pos(end)-1);
    volPath=sprintf('%s/%s',homeVolumes,volName);
    rtn=textscan(volName,'x%d/y%d/x%dy%dz%d_s%d_%d_%d_e%d_%d_%d');
    st=double([rtn{6} rtn{7} rtn{8}]);
    off=floor((st-1)/mipFactor);
    
    volExpert=get_hdf5_file(hdf5expert,'/main',off+1,off+sizeVolume);
    volExpert=ismember(volExpert,segID);   % includes all the tasks in this volume
    
    volSeg=getVolumeSegmentation([volPath segRawPostfix]); % raw segmentation of the volume
    segSeeds=convSegSql(seeds{j},0);
    volSeed=ismember(volSeg,segSeeds);
    sizeSeed=sum(sum(sum(volSeed)));
    
    % extract validation for this task
    cc=bwconncomp(volExpert,26);
    b=false;
    for i=1:cc.NumObjects    
        volExpertTask=false(sizeVolume);
        volExpertTask(cc.PixelIdxList{i})=1;
        
        overlap=sum(sum(sum(volExpertTask.*volSeed)));
        if (overlap>sizeSeed*0.9)
            b=true;
            break;
        end
    end
    if ~(b)
        fprintf('* [%d]\n experts validation cannot be found',taskID(j));
        continue;
    end
    
    segTruth=setdiff(volSeg(volExpertTask),0);
    
    % exclude false segments (wrongly detected due to mismatch)
    overlap=arrayfun(@(x) sum(volSeg(volExpertTask)==x),segTruth);
    sizeSegment=arrayfun(@(x) sum(sum(sum(volSeg==x))),segTruth);
    segTruth((overlap./sizeSegment)<0.9)=[];
    
    % print out ground truth info
    fprintf('* [%d]\n %s\n ',taskID(j),volName);
    fprintf('%d ',segTruth);
    fprintf('\n');

end

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

%%
function [seg]=convSegSql(instr,thr,v)
% {"30":1,"1285":1,"1357":1,"1691":1,"1697":1,"1708":1,"1722":1,"1902":1,"2100":1,"2110":1}

if (strcmp(instr,'[]') || strcmp(instr,'{}'))
    seg=[];
    return;
end

if (~exist('thr','var'))
    thr=-1;
end

pl=findstr(instr,'{');
pr=findstr(instr,'}');

instr=instr(pl+1:pr-1);
pc=findstr(instr,',');
pl=[1 pc+1];
pr=[pc-1 numel(instr)];

seg=[];
for i=1:numel(pl)
    row=instr(pl(i):pr(i));
    rtn=textscan(row,'"%d":%s');
    if (strcmp(rtn{2}{:},'null'))
        prob=0;
    else
        prob=str2double(rtn{2}{:});
    end
    if (prob>thr)
        seg=[seg rtn{1}];
    end
end

if (exist('v','var'))
    fprintf('%d ',seg);
    fprintf('\n');
end

end

