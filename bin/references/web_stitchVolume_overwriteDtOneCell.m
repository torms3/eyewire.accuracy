%% 
function web_stitchVolume_overwriteDtOneCell(hdf5out,expValPath,cellID)
% out_name.h5/omniData/e2198/completedCells/jamb010/,11

homeVolumes='/omelette/2/omniweb_data';
homeOmniVolumes='/omniData/e2198';

addpath /omelette/2/jk/omniweb/bin
addpath /omelette/2/jk/omniweb/bin/mysql
addpath /omelette/2/jk/e2198/bin/hdf5
addpath /omelette/2/jk/e2198/bin/helper
addpath /omelette/2/jk/e2198/bin/buildOmni

global sizeofUint32 sizeChunkLinear sizeChunk sizeVolume0 sizeVolume mipLevel mipFactor segRawPostfix segRawPostfix0 
mipLevel=1;
mipFactor=2^mipLevel;
segRawPostfix=['/segmentations/segmentation1/' num2str(mipLevel) '/volume.uint32_t.raw'];
segRawPostfix0='/segmentations/segmentation1/0/volume.uint32_t.raw';
sizeChunk=[128 128 128];
sizeVolume0=[256 256 256];
sizeVolume=sizeVolume0/mipFactor;
sizeChunkLinear=prod(sizeChunk);
sizeofUint32=4;

%% to find offset, start coord from each volume. and get size of volume
pathChildRepository=expValPath;
[lstVolLett lstSegInVol]=getSegments(pathChildRepository);
N=numel(lstVolLett);
lstBoxVolumes=zeros(N,6);
filelist=cell(N,1);
for i=1:numel(lstVolLett)
    lstBoxVolumes(i,:)=hvGetVolumeBoxFromVolumeLetter(homeOmniVolumes,lstVolLett{i});
    filelist{i}=hvGetVolumeNameFromLetter(homeOmniVolumes,lstVolLett{i});
end
sizeVolumes=lstBoxVolumes(:,4:6)-lstBoxVolumes(:,1:3)+1; % num chunks

o0=zeros(N,3);
sz0=zeros(N,3);
for i=1:N
    o0(i,:)=getOffsetFromBox(lstBoxVolumes(i,1:3));
    sz0(i,:)=sizeVolumes(i,:).*sizeChunk;
end
% merged cube size is thus determined for mip0
sizeVolumeInVoxels0=max(o0+sz0,[],1)-min(o0,[],1);
sizeVolumeInChunks=ceil(ceil(sizeVolumeInVoxels0/mipFactor)./sizeChunk);
sizeVolumeInVoxels=sizeVolumeInChunks.*sizeChunk;
stInChunks=min(lstBoxVolumes(:,1:3),[],1);
offInVoxels0=getOffsetFromBox(stInChunks);

%% write Omni reconstruction
if (exist(hdf5out,'file'))
   delete(hdf5out);
end
create_hdf5_file(hdf5out,'/main',sizeVolumeInVoxels,sizeChunk,[0 0 0],'uint');

% bBoxFill=zeros(sizeVolumeInChunks);
% for i=1:N
%     volBox=hvGetVolumeBoxFromVolumeName(filelist{i});
%     volLett=lstVolLett{i};
%     volName=filelist{i};
%     fprintf('reading chunks from %s ...',volLett);
    
%     volSizeChunks0=volBox(4:6)-volBox(1:3)+1;
%     volSizePixels0=volSizeChunks0.*sizeChunk;
%     volOffset0=(volBox(1:3)-stInChunks).*sizeChunk;    
%     volSizePixels=ceil(volSizePixels0/mipFactor);
%     volSizeChunks=ceil(volSizePixels./sizeChunk);
%     volOffset=floor(volOffset0/mipFactor);

%     filepath=sprintf('%s/%s.files/%s',homeOmniVolumes,volName,segRawPostfix);
%     f=fopen(filepath,'r');    
%     for x=1:volSizeChunks(1)
%        for y=1:volSizeChunks(2)
%             for z=1:volSizeChunks(3)
%                 fprintf(' [%d/%d %d/%d %d/%d]\n',...
%                     x,volSizeChunks(1),y,volSizeChunks(2),z,volSizeChunks(3));
                
%                 % get chunk location and read
%                 subChunk=[x y z];
%                 indChunk=sub2ind(volSizeChunks,x,y,z);
%                 off=(sizeofUint32*(indChunk-1)*sizeChunkLinear);
%                 fseek(f,off,'bof');
%                 chunk=reshape(fread(f,sizeChunkLinear,'*uint32'),sizeChunk);
%                 chunk=uint32(ismember(chunk,lstSegInVol{i})); 
%                 if (sum(chunk>0)==0)
%                     fprintf('    >> chunk blank\n');
%                     continue;
%                 end                
                
%                 % find position to write in out volume, possibly into multiple chunks
%                 coordSrcChunkSt=volOffset+(subChunk-1).*sizeChunk+1;
%                 coordSrcChunkEd=min(coordSrcChunkSt+sizeChunk-1,sizeVolumeInVoxels);  % coord of source chunk, in dst volume
%                 locations=findDestLocation(coordSrcChunkSt,coordSrcChunkEd);  

%                 for j=1:size(locations.subChunk,1)
%                     subDstChunk=locations.subChunk(j,:);
%                     coordBoxInSrcChunk=locations.coordBoxInSrcChunk(j,:);
%                     coordBoxInDstChunk=locations.coordBoxInDstChunk(j,:);
%                     chunkSrc=zeros(size(chunk),'uint32');
%                     chunkSrc(coordBoxInDstChunk(1):coordBoxInDstChunk(4),coordBoxInDstChunk(2):coordBoxInDstChunk(5),coordBoxInDstChunk(3):coordBoxInDstChunk(6))=...
%                         chunk(coordBoxInSrcChunk(1):coordBoxInSrcChunk(4),coordBoxInSrcChunk(2):coordBoxInSrcChunk(5),coordBoxInSrcChunk(3):coordBoxInSrcChunk(6));
%                     if (sum(chunkSrc>0)==0)
%                         continue;
%                     end

%                     chunkDst=zeros(sizeChunk,'uint32');
%                     coordDstChunkSt=(subDstChunk-1).*sizeChunk+1;
%                     coordDstChunkEd=coordDstChunkSt+sizeChunk-1;                                        
%                     if (bBoxFill(subDstChunk(1),subDstChunk(2),subDstChunk(3)))
%                         % if this chunk location overlaps earlier chunks,
%                         % read previous data and "underwrite"
%                         chunkDst=get_hdf5_file(hdf5out,'/main',coordDstChunkSt,coordDstChunkEd);
%                         chunkDst=uint32(chunkDst);
%                     end
%                     chunkDst=chunkDst+uint32(chunkSrc.*uint32((chunkDst==0))); %underwrite
%                     bBoxFill(subDstChunk(1),subDstChunk(2),subDstChunk(3))=1;
%                     fprintf('    >> %d %d %d (%d~%d, %d~%d, %d~%d)\n',subDstChunk,reshape(coordBoxInDstChunk,[3 2])');                    
%                     write_hdf5_file(hdf5out,'/main',coordDstChunkSt,coordDstChunkEd,uint32(chunkDst));
%                 end                
%             end
%         end
%     end
%     fclose(f);
% end

% chunk=zeros(sizeChunk,'uint32');
% for x=1:sizeVolumeInChunks(1)
%     for y=1:sizeVolumeInChunks(2)
%         for z=1:sizeVolumeInChunks(3)
%             if (bBoxFill(x,y,z)==0)
%                 stCoordInCube=([x y z]-1).*sizeChunk+1;
%                 edCoordInCube=[x y z].*sizeChunk;
%                 fprintf('filling up [%d %d %d]\n',x,y,z);
%                 write_hdf5_file(hdf5out,'/main',stCoordInCube,edCoordInCube,chunk); 
%             end
%         end
%     end
% end



%% write eyewire reconstruction
mysql('open','127.0.0.1:13306','omnidev','we8pizza');
mysql('use omniweb');

[task_id task_cell volume_path]=...
    mysql(sprintf('select tasks.id,tasks.cell,volumes.path from tasks join volumes where tasks.cell=%d and tasks.status=0 and tasks.segmentation_id=volumes.id order by tasks.id',cellID));

N=numel(task_id);
for i=1:N

    fprintf('*(%d/%d) task [%d]\n',i,N,task_id(i));    
    
    query=sprintf('select segments,weight from validations where task_id=%d and status=9',task_id(i));
    [validation_segments_str validation_numUsers]=mysql(query);
    if (validation_numUsers<3 || isempty(validation_segments_str))
        continue;
    end    
    validation_segments=webtasks_segstr2seg(validation_segments_str{:},exp(-0.16*validation_numUsers)+0.2);
    
    pos=strfind(volume_path{i},'/');
    volName=volume_path{i}(pos(end-1)+1:pos(end)-1);
    rtn=textscan(volName,'x%dy%dz%d_s%d_%d_%d_e%d_%d_%d');
    x=rtn{1}; y=rtn{2};
    volPath=sprintf('%s/x%02d/y%02d/%s',homeVolumes,x,y,volName);
    rtn=textscan(volName,'x%dy%dz%d_s%d_%d_%d_e%d_%d_%d');
    st=double([rtn{4} rtn{5} rtn{6}]);
    off=floor((st-1-offInVoxels0)/mipFactor);
    off2=ceil((st-1-offInVoxels0)/mipFactor);
    if (off~=off2)
        fprintf('diff!!\n');
    end
    if any(off<0)
        fprintf('  out of data bound. skipping\n');
        continue;
    end
    
    segID=1;
    FN=segID;
    FP=segID*10+2;
    TR=segID*10+3;
    volSrc=uint32(get_hdf5_file(hdf5out,'/main',off+1,off+sizeVolume));
    volExpert=ismember(volSrc,segID); 
    volSeg=getVolumeSegmentation(volPath); % raw segmentation of the volume
    volEyewire=ismember(volSeg,validation_segments).*(~ismember(volSrc,[FP TR]));
    vol=TR*volExpert.*volEyewire+FP*(~volExpert).*volEyewire+FN*volExpert.*(~volEyewire);
    volOut=volSrc.*uint32(vol==0)+uint32(vol); %overwrite
    
    write_hdf5_file(hdf5out,'/main',off+1,off+sizeVolume,volOut);                
end

mysql('close');

filename=sprintf('omnify.cmd');
fo=fopen(filename,'w');
fprintf(fo,'create:%s.omni\n',hdf5out);
fprintf(fo,'loadHDF5seg:%s\n',hdf5out);
fprintf(fo,'setSegAbsOffset:1,%d,%d,%d\n',offInVoxels0);
fprintf(fo,'setSegResolution:1,%d,%d,%d\n',mipFactor,mipFactor,mipFactor);
fprintf(fo,'mesh\n');
fprintf(fo,'close\n');
fclose(fo);

system(['gdb -ex run --batch --args /Users/balkamm/omni/omni.desktop --headless --cmdfile ' filename]);
system(sprintf('chmod -R 777 %s.omni*',hdf5out));

end

%%
function [vol]=getVolumeSegmentation(fn)

global mipLevel segRawPostfix segRawPostfix0 

if mipLevel==0 || mipLevel==1
    vol=getVolumeSegmentation_lowmip([fn segRawPostfix]);
else
    vol=getVolumeSegmentation_highmip([fn segRawPostfix0]);
end

end

function [vol]=getVolumeSegmentation_lowmip(fn)

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

function [vol]=getVolumeSegmentation_highmip(fn)
        
global sizeofUint32 sizeChunk sizeChunkLinear sizeVolume sizeVolume0 mipFactor 

sizeChunkNew=sizeChunk/mipFactor;
sizeVolumeInChunks=sizeVolume0./sizeChunk;
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
            chunkNew=resize(chunk,mipFactor);
            st=([x y z]-1).*sizeChunkNew+1;
            ed=min(([x y z]).*sizeChunkNew,sizeVolume);
            vol(st(1):ed(1),st(2):ed(2),st(3):ed(3))=chunkNew;
        end
    end
end
fclose(fp);

end

function output=resize(input,factor)

output=zeros(ceil(size(input)/factor),class(input));
cnt=0;
for i=1:factor:size(input,3)
    cnt=cnt+1;
    output(:,:,cnt)=imresize(input(:,:,i),1/factor,'nearest');
end

end


%%
function [locations]=findDestLocation(coordSrcChunkSt,coordSrcChunkEd)

global sizeChunk

coordSrcChunk=[coordSrcChunkSt coordSrcChunkEd];
offsetSrcChunk=coordSrcChunkSt-1;

boxDstChunk(1:3)=ceil(coordSrcChunkSt./sizeChunk);
boxDstChunk(4:6)=ceil(coordSrcChunkEd./sizeChunk);
numDstChunk=prod(boxDstChunk(4:6)-boxDstChunk(1:3)+1);

n=0;
subChunk=zeros(numDstChunk,3);
coordBoxInDstChunk=zeros(numDstChunk,6);
coordBoxInSrcChunk=zeros(numDstChunk,6);
for x=boxDstChunk(1):boxDstChunk(4)
    for y=boxDstChunk(2):boxDstChunk(5)
        for z=boxDstChunk(3):boxDstChunk(6)
            n=n+1;
            subChunk(n,:)=[x y z];
            offsetDstChunk=(subChunk(n,:)-1).*sizeChunk;
            coordDstChunk(1:3)=(subChunk(n,:)-1).*sizeChunk+1;
            coordDstChunk(4:6)=coordDstChunk(1:3)+sizeChunk-1;
            overlap=getOverlapBoxCoord(coordSrcChunk,coordDstChunk);
            coordBoxInDstChunk(n,:)=overlap-repmat(offsetDstChunk,[1 2]);
            coordBoxInSrcChunk(n,:)=overlap-repmat(offsetSrcChunk,[1 2]);
        end
    end
end

locations.subChunk=subChunk;
locations.coordBoxInSrcChunk=coordBoxInSrcChunk;
locations.coordBoxInDstChunk=coordBoxInDstChunk;

end

function [boxOverlap]=getOverlapBoxCoord(box1,box2)

boxOverlap=[];
bb=zeros(1,6);
for i=1:3
    a=intersect(box1(i):box1(i+3),box2(i):box2(i+3));
    if (isempty(a))
        return
    end
    bb(i)=min(a);
    bb(i+3)=max(a);
end
boxOverlap=bb;

end
%% sort child files.
function [lstVolLett lstSegInVol]=getSegments(home)

files=dir([home '/*.consensus.child']);
lstLett=cell(numel(files),1);
for i=1:numel(files)
    filename=sprintf('%s',files(i).name);
    pos=findstr(filename,'_');
    lett=filename(1:pos-1);
    lstLett{i}=lower(lett);
end
lstVolLett=unique(lstLett);

lstSegInVol=cell(numel(lstVolLett),1);
for j=1:numel(lstVolLett)
    files=dir([home '/' lstVolLett{j} '_*.consensus.child']);
    files=[files; dir([home '/' upper(lstVolLett{j}) '_*.consensus.child'])];
    lstSeg=[];
    for i=1:numel(files)
        filepath=[home '/' files(i).name];
        seg=omReadChildList(filepath);
        lstSeg=[lstSeg; seg.lSprVxl];
    end
    lstSegInVol{j}=setdiff(lstSeg,0);
end

end

%%
function [offset]=getOffsetFromBox(box)

global sizeChunk    
offset=(box(1:3)-[1 0 0]).*sizeChunk+18;

end

