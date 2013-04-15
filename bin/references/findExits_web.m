function [status,tasks,newVolumes]=findExits_web(homeVols,homeTasks,volumeLetter,seedSeg,user)

status='done';
tasks.name=[];
tasks.coord=[];
tasks.seed=[];
newVolumes=[];

%% chunk for input before all the other stuffs
fn=sprintf('%s/%s_%s.%s.child',homeTasks,volumeLetter,seedSeg,user);
if (exist(fn,'file'))
    fileListChildren=fn;
else
    fn=sprintf('%s/%s_%s.%s.child',homeTasks,upper(volumeLetter),seedSeg,user);
    if (exist(fn,'file'))
        fileListChildren=fn;
    else
        status='nofile';
        return;
    end
end

% global constants and variables
DUST_SIZE_THR_2D=25;
FALSE_OBJ_SIZE_THR=125;
global sizeofUint32 sizeChunk sizeChunkLinear
sizeofUint32=4;
sizeChunk=[128 128 128];
sizeChunkLinear=prod(sizeChunk);

global homeFiles homeVolumes postfixFileSegmentation xyz
homeVolumes=homeVols;
homeFiles=homeTasks;
postfixFileSegmentation='.files/segmentations/segmentation1/0/volume.uint32_t.raw';
xyz={'-x' '-y' '-z' '+x' '+y' '+z'};

%% obtain volume information
global lstVolumesBox lstVolumesSize 
lstVolumesBox=findAvailableVolumesBox(homeVolumes);
lstVolumesSize=lstVolumesBox(:,4:6)-lstVolumesBox(:,1:3)+1;

boxCenterVolume=getVolumeBoxFromVolumeLetter(homeVolumes,volumeLetter);
nameCenterVolume=getVolumeNameFromLetter(homeVolumes,volumeLetter);
idxCenterVolume=find(all(bsxfun(@eq,lstVolumesBox,boxCenterVolume),2));

%% find all segments that faces the volume boundaries in the center volume
seg=omReadChildList(fileListChildren);
lstSegmentsInCenterVolume=seg.lSprVxl;
pathCenterVolumeSegmentation=sprintf('%s/%s%s',homeVolumes,nameCenterVolume,postfixFileSegmentation);

vol=getVolumeSegmentation(pathCenterVolumeSegmentation,idxCenterVolume);

fileOut=sprintf('%s/%s_%s.%s.tasks',homeTasks,volumeLetter,seedSeg,user);
fo=fopen(fileOut,'w');

% process for each face: x,y,z_min = 1,2,3  /  x,y,z_max=4,5,6
for i=1:6
    fprintf(fo,'to %s direction ... ',xyz{i});

    [face,sliceFace]=getFace(vol,i);
    lstSegOnFace=intersect(face(:),lstSegmentsInCenterVolume);  % recontruced cell's segments on volume face
    if isempty(lstSegOnFace)
        fprintf(fo,'no exit found\n');
        continue; 
    end    
    
    % conncomp for them, and remove dust exits
    bwFace=ismember(face,lstSegmentsInCenterVolume);
    ccFace=bwconncomp(bwFace,8);
    bRemove=cellfun(@(x) numel(x),ccFace.PixelIdxList)<DUST_SIZE_THR_2D;
    ccFace.PixelIdxList(bRemove)=[];
    ccFace.NumObjects=numel(ccFace.PixelIdxList);
    if (ccFace.NumObjects==0)
        fprintf(fo,'no exit found\n');
        continue; 
    end    
    fprintf(fo,'%d exit points:\n',ccFace.NumObjects);
    
    % find bbox of exit branch conncomp, and corresponding neighbor volume
    coordBBoxExitBranch=getBoundingBoxesCC(boxCenterVolume,ccFace,i,sliceFace);   % "coord" is for global coord in all.omni
    lstNeighborVolumesIndex=[];
    for k=1:size(coordBBoxExitBranch,1)
        bbox=coordBBoxExitBranch(k,:);
        nbID=findNeighborVolumeForBBox(idxCenterVolume,bbox,i);
        if (nbID==0)
            fprintf(fo,'   !!! exit (%d %d %d): volume to [%s] is missing !!!\n',round((bbox(1:3)+bbox(4:6))/2),xyz{i});
            if (any(strcmp(newVolumes,xyz{i})))
                continue;
            end
            newVolumes=[newVolumes {xyz{i}}];
            status='newvol';
        else
            lstNeighborVolumesIndex=[lstNeighborVolumesIndex; nbID];
        end
    end
    lstNeighborVolumesIndex=unique(lstNeighborVolumesIndex);
    if (isempty(lstNeighborVolumesIndex))
        % exit branches found but no available volume 
        continue;
    end
    lstNeighborVolumesBox=lstVolumesBox(lstNeighborVolumesIndex,:);

    % divide up the overlap region of center volume wrt neighbor volume location,     
    % process for each neighbor volume
    history=[];
    for t=1:size(lstNeighborVolumesBox,1)
        boxOverlap=getOverlapBox(boxCenterVolume,lstNeighborVolumesBox(t,:),'box');
        volOverlap=extractOverlapRegion(vol,boxCenterVolume,boxOverlap);
        
        [lettNb nameNb]=getVolumeFromBox(lstNeighborVolumesBox(t,:));
        boxVolNb=getVolumeBoxFromVolumeLetter(homeVolumes,lettNb);
        rtn=textscan(lettNb,'x%dy%dz%d');
        pathNb=sprintf('%s/x%02d/y%02d/%s%s',homeVolumes,rtn{1},rtn{2},nameNb,postfixFileSegmentation);
        volNb=getVolumeSegmentation(pathNb,lstNeighborVolumesIndex(t));
        volOverlapNb=extractOverlapRegion(volNb,boxVolNb,boxOverlap);
        
        % 3D conncomp in overlap region 
        bwOverlap=ismember(volOverlap,lstSegmentsInCenterVolume);
        ccOverlap=bwconncomp(bwOverlap,26);
        for k=1:ccOverlap.NumObjects
            
            dd=i-3*(floor((i-1)/3));   % 1 2 3 1 2 3
            kk=(floor((i-1)/3));  % 0 0 0 1 1 1                        
            sizeOverlap=boxOverlap(4:6)-boxOverlap(1:3)+1;
            sizeCenterVolume=lstVolumesSize(idxCenterVolume,:);
            sf=sliceFace-kk*(sizeCenterVolume(dd)-sizeOverlap(dd));

            % for only those actually and sufficiently touch the boundary
            % to exclude those "in" the overlap region, but not make exit
            [x y z]=ind2sub(sizeOverlap,ccOverlap.PixelIdxList{k});
            sub=[x y z];
            if (sum(sub(:,dd)==sf)<DUST_SIZE_THR_2D)
                continue;
            end
            
            % find all the exit points of this 3d conncomp
            bwObjectFace=false(sizeOverlap);
            bwObjectFace(ccOverlap.PixelIdxList{k})=1;
            idx={':' ':' ':'};
            idx(dd)={sf};
            bwObjectFace=squeeze(bwObjectFace(idx{:}));    % face slice of this conncomp object
            ccObjectFace=bwconncomp(bwObjectFace,8);
            coordCenterOfExits=getCentersOfCC(boxOverlap,ccObjectFace,i,sf);   % centers of the conncomps
            
            % corresponding object in neighbor
            segInObjectNb=volOverlapNb(ccOverlap.PixelIdxList{k});
            segInObjectNb=segInObjectNb(segInObjectNb~=0);
            lstSegInObjectNb=unique(segInObjectNb);
            if (isempty(lstSegInObjectNb))
                fprintf(fo,'   ??? overlap box [%d %d %d-%d %d %d], 3d cc %d has no entry\n',boxOverlap,k);
                continue;
            end
            
            % exclude false overlap segments:
            sizeSegInObjectNb=arrayfun(@(x) sum(segInObjectNb==x),lstSegInObjectNb);
            % below lines are replaced due to calculation time issue
            % [[sizeSegInOverlapNb=arrayfun(@(x) sum(volOverlapNb(:)==x),lstSegInObjectNb);
            % lstExclude=(sizeSegInObjectNb./sizeSegInOverlapNb)<0.5;]]
            sizeWholeObjectNb=numel(ccOverlap.PixelIdxList{k});
            bExclude=logical(((sizeSegInObjectNb/sizeWholeObjectNb)<0.01).*(sizeSegInObjectNb<FALSE_OBJ_SIZE_THR));
            lstSegInObjectNb(bExclude)=[];
            sizeSegInObjectNb(bExclude)=[];
            [maxSz maxID]=max(sizeSegInObjectNb);

            % output new tasks or report already traced
            task=sprintf('%s_%d',lettNb,lstSegInObjectNb(maxID));
            if any(strcmp(history,task))
                continue;
            end
            history=[history {task}];
            file=isTraced(homeFiles,lettNb,lstSegInObjectNb,sizeSegInObjectNb);
            if (isempty(file)) % new task            
                fprintf(fo,'   [%s]\n',task);                            
                tasks.name=[tasks.name {task}];
                tasks.coord=[tasks.coord {coordCenterOfExits}];
                lstSegInObjectNb([maxID 1])=lstSegInObjectNb([1 maxID]);
                tasks.seed=[tasks.seed {lstSegInObjectNb}];
            else
                fprintf(fo,'   %s already traced %s\n',task,file);
            end
        end
    end
    
end

fclose(fo);

end

%%
function [file]=isTraced(homeFiles,letter,lstSegNew,numOcc)

searchStr=sprintf('%s/%s_*.child',homeFiles,letter);
files=dir(searchStr);
[ss,idx]=sort([files.datenum]);

total=sum(numOcc(:));
for i=1:numel(files)
    path=sprintf('%s/%s',homeFiles,files(idx(i)).name);
    lstSeg=omReadChildList(path);
    c=intersect(lstSeg.lSprVxl,lstSegNew);
    sz=arrayfun(@(x) numOcc(lstSegNew==x),c);
    overlap=sum(sz(:));
    if ((overlap/total)>0.5)
        file=files(idx(i)).name;
        return
    end
end

file='';

end

%%
function [part]=extractOverlapRegion(vol,boxVol,boxOverlap)

off=boxOverlap(1:3)-boxVol(1:3);
sz=boxOverlap(4:6)-boxOverlap(1:3)+1;

part=vol(off(1)+1:off(1)+sz(1),off(2)+1:off(2)+sz(2),off(3)+1:off(3)+sz(3));

end


%% 
function [output]=getOverlapBox(box1,box2,option)

if (strcmp(option,'box'))
    output=zeros(1,6);
else
    output=0;    
end

if (all(box1==0,2) || all(box2==0,2))
    return
end

ob=zeros(1,6);
for i=1:3
    a=intersect(box1(i):box1(i+3),box2(i):box2(i+3));
    if (isempty(a))
        return
    end
    ob(i)=min(a);
    ob(i+3)=max(a);
end
overlapSize=(ob(4)-ob(1)+1)*(ob(5)-ob(2)+1)*(ob(6)-ob(3)+1);
overlapBox=ob;

if (strcmp(option,'box'))
    output=overlapBox;
else
    output=overlapSize;    
end

end

%%
function [neighborVolumeID]=findNeighborVolumeForBBox(idxCenterVolume,bbox,direction)

global lstVolumesBox

boxCenterVolume=lstVolumesBox(idxCenterVolume,:);
N=size(lstVolumesBox,1);
candVolumesBox=lstVolumesBox;

kk=(floor((direction-1)/3));  % 0 0 0 1 1 1
ss=-2*kk+1;       % +1 +1 +1 -1 -1 -1
comple=direction+ss*3;     % 4 5 6 1 2 3
ss=-ss;            % -1 -1 -1 +1 +1 +1

Cd=ss*boxCenterVolume(direction);
for i=1:N
    Nd=ss*candVolumesBox(i,direction);
    Nc=ss*candVolumesBox(i,comple);
    if ~(Nd>Cd && Cd>Nc)
        candVolumesBox(i,:)=zeros(1,6);
    end
end

% first get volume with the max overlap with bbox (exclude non-max volumes)
overlapSize=zeros(N,1);
for i=1:N
    overlapSize(i)=getOverlapBox(candVolumesBox(i,:),bbox,'size');
end
if (max(overlapSize)==0)
    neighborVolumeID=0;
    return;
end
idx=find(logical((overlapSize~=max(overlapSize))+(overlapSize==0)));
for i=1:numel(idx)
    candVolumesBox(idx(i),:)=zeros(1,6);
end

% there still can be multiple volumes, get the max overlap with center volume
for i=1:N
    overlapSize(i)=getOverlapBox(candVolumesBox(i,:),boxCenterVolume,'size');
end
[sizeMaxOverlap, idxMaxOverlapVolume]=max(overlapSize);

if (overlapSize==0)
    neighborVolumeID=0;
else
    neighborVolumeID=idxMaxOverlapVolume;
end

end

%%
function [centers]=getCentersOfCC(volumeBox,cc,direction,sliceFace)

dimOneThick=direction-3*(floor((direction-1)/3));   % 1 2 3 1 2 3
tt=(floor((direction-1)/3));  % 0 0 0 1 1 1

% center, local coordinate
centcc=regionprops(cc,'Centroid');
centOnFace=round(reshape([centcc.Centroid],2,[])');
centOnFace(:,[1 2])=centOnFace(:,[2 1]);
centOnFace=insertAtCol(centOnFace,dimOneThick,0);    

% for mapping onto global coord:
% offset
offset=volumeBox(1:3)-1;
% szvol
ss=volumeBox(4:6)-volumeBox(1:3)+1;
szvol=[0 0 0];
szvol(dimOneThick)=tt*ss(dimOneThick);
% slice
sf=sliceFace-tt*ss(dimOneThick);
slice=[0 0 0];
slice(dimOneThick)=sf;

centers=bsxfun(@plus,centOnFace,(szvol+offset+slice));

end

%%
function [bboxes]=getBoundingBoxesCC(volumeBox,cc,direction,sliceFace)

dimOneThick=direction-3*(floor((direction-1)/3));   % 1 2 3 1 2 3
tt=(floor((direction-1)/3));  % 0 0 0 1 1 1

% bounding box, local coordinate
bbcc=regionprops(cc,'BoundingBox');
bboxOnFace=round(reshape([bbcc.BoundingBox],4,[])');
bboxOnFace(:,[1 2 3 4])=bboxOnFace(:,[2 1 4 3]);
bboxOnFace(:,[3 4])=bboxOnFace(:,[1 2])+bboxOnFace(:,[3 4])-1;
bboxOnFace=insertAtCol(bboxOnFace,dimOneThick,0);
bboxOnFace=insertAtCol(bboxOnFace,dimOneThick+3,0);

% for mapping onto global coord:
% offset
offset=volumeBox(1:3)-1;
% szvol
ss=volumeBox(4:6)-volumeBox(1:3)+1;
szvol=[0 0 0];
szvol(dimOneThick)=tt*ss(dimOneThick);
% slice
sf=sliceFace-tt*ss(dimOneThick);
slice=[0 0 0];
slice(dimOneThick)=sf;

bboxes=bsxfun(@plus,bboxOnFace,repmat((offset+szvol+slice),1,2));

end

%% 
function [out]=insertAtCol(mat,col,val)
out=repmat(val,size(mat,1),size(mat,2)+1);
try
    out(:,1:col-1)=mat(:,1:col-1);
catch
end
try
    out(:,col+1:end)=mat(:,col:end);
catch
end
end

%% find "first" plane that actually has data
function [face,sliceFace]=getFace(vol,direction)

sizeVolume=size(vol);
kk=(floor((direction-1)/3));  % 0 0 0 1 1 1
dimOneThick=direction-3*kk;   % 1 2 3 1 2 3
start=(sizeVolume(dimOneThick)-1)*kk+1;  % 1 1 1 s1 s2 s3
stp=-2*kk+1;       % +1 +1 +1 -1 -1 -1

% simplified: sf=2 for [-], sf=(chunk-1) for [+]
sliceFace=start+stp;
idx={':' ':' ':'};
idx(dimOneThick)={sliceFace};
face=squeeze(vol(idx{:}));

end    

%% 
function [vol]=getVolumeSegmentation(fn,idVol)

global sizeofUint32 sizeChunk sizeChunkLinear lstVolumesSize

szVol=lstVolumesSize(idVol,:);
szVolChunks=szVol./sizeChunk;
vol=zeros(szVol,'uint32');

fp=fopen(fn,'r');
for x=1:szVolChunks(1)
    for y=1:szVolChunks(2)
        for z=1:szVolChunks(3)
            sub=[x y z];
            indChunk=sub2ind(szVolChunks,sub(1),sub(2),sub(3));
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
function [lstBox]=findAvailableVolumesBox(home)

strFiles=ls(sprintf('%s/x*/*/*.omni',home));
posNewLine=findstr(strFiles,char(10));
pl=[1 posNewLine(1:end-1)+1];
pr=posNewLine-1;
lstOmniVolumeFiles=cell(numel(pl),1);
for i=1:numel(pl)
    lstOmniVolumeFiles{i}=strFiles(pl(i):pr(i));
end

count=0;
try
    for i=1:numel(lstOmniVolumeFiles)
        pp=findstr(lstOmniVolumeFiles{i},'/');
        filename=lstOmniVolumeFiles{i}(pp(end)+1:end);
        rtn=textscan(filename,'%s s%d %d %d e%d %d %d.omni.files','delimiter','_');
        dims=cellfun(@(x) size(x,1),rtn);

        if all(dims)
            count=count+1;
            lstBox(count,1:6)=double([rtn{2:7}]);
        end
    end
catch ME
    fprintf('%d: %s\n',i,ME.message);
    return;
end

end

function [box]=getVolumeBoxFromVolumeLetter(home,letter)

rtn=textscan(letter,'x%dy%dz%d');
searchStr=sprintf('%s/x%02d/y%02d/%s_*.omni',home,rtn{1},rtn{2},letter);
file=dir(searchStr);

if (numel(file)~=1)
    box=zeros(1,6);
    return
end

volName=file.name;
rtn=textscan(volName,'%s s%d %d %d e%d %d %d.omni','delimiter','_');
box=double([rtn{2:7}]);

end

function [name]=getVolumeNameFromLetter(home,letter)

rtn=textscan(letter,'x%dy%dz%d');
searchStr=sprintf('%s/x%02d/y%02d/%s_*.omni',home,rtn{1},rtn{2},letter);
file=dir(searchStr);

if (numel(file)~=1)
    name='';
else
    name=sprintf('x%02d/y%02d/%s',rtn{1},rtn{2},file.name);
end

end

function [letter,name]=getVolumeFromBox(boxVolume)

sz=[256 256 256];
ov=[32 32 32];
stOff=[242 274 210];

x=boxVolume(1:3);
X=floor((x-stOff-1)./(sz-ov));

off=stOff+X.*(sz-ov);
st=off+1;
ed=off+sz;

letter=sprintf('x%02dy%02dz%02d',X);
name=sprintf('x%02dy%02dz%02d_s%d_%d_%d_e%d_%d_%d.omni',X,st,ed);

end

%% read child list from omni exported txt file
function [seg]=omReadChildList(FileChildList)

%example:
%25637 : 0, 0, 552
%27270 : 25637, 0.949978, 46479

fi=fopen(FileChildList,'r');
List=fscanf(fi,'%d : %d, %f, %d\n',[4 inf]);
fclose(fi);

seg.lSprVxl=List(1,:)';
seg.szSprVxl=List(4,:)';
seg.nSprVxl=numel(seg.lSprVxl);

end
