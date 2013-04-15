function omnify( DB_MAPs )

homeVolumes='/omelette/2/omniweb_data';
homeOmniVolumes='/omniData/e2198';

addpath /omelette/2/jk/omniweb/bin
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
[lstVolLett lstSegInVol] = getSegments( pathChildRepository );
N=numel(lstVolLett);
lstBoxVolumes=zeros(N,6);
filelist=cell(N,1);
for i=1:numel(lstVolLett)
    lstBoxVolumes(i,:) = hvGetVolumeBoxFromVolumeLetter( homeOmniVolumes, lstVolLett{i} );
    filelist{i} = hvGetVolumeNameFromLetter( homeOmniVolumes, lstVolLett{i} );
end
sizeVolumes=lstBoxVolumes(:,4:6)-lstBoxVolumes(:,1:3)+1; % num chunks
o0  = zeros(N,3);
sz0 = zeros(N,3);
for i = 1:N
    
    o0(i,:)	 = getOffsetFromBox( lstBoxVolumes(i,1:3) );
    sz0(i,:) = sizeVolumes(i,:).*sizeChunk;

end
% merged cube size is thus determined for mip0
sizeVolumeInVoxels0=max(o0+sz0,[],1)-min(o0,[],1);
sizeVolumeInChunks=ceil(ceil(sizeVolumeInVoxels0/mipFactor)./sizeChunk);
sizeVolumeInVoxels=sizeVolumeInChunks.*sizeChunk;
stInChunks=min(lstBoxVolumes(:,1:3),[],1);
offInVoxels0=getOffsetFromBox(stInChunks);


%%
%
T 	= DB_MAPs.T;
VOL = DB_MAPs.VOL;

%% Cube-wise processing
%
keys 	= T.keys;
vals 	= T.values;
% for i = 1:T.Count

% 	tID = keys{i};
% 	fprintf('*(%d/%d) task [%d]\n',i,T.Count,tID);

% 	tInfo = vals{i};
% 	volInfo = VOL(tInfo.chID);

% 	pos=strfind(volInfo.path,'/');
%     volName=volume_path{i}(pos(end-1)+1:pos(end)-1);
%     rtn=textscan(volName,'x%dy%dz%d_s%d_%d_%d_e%d_%d_%d');
%     x=rtn{1}; y=rtn{2};
%     volPath=sprintf('%s/x%02d/y%02d/%s',homeVolumes,x,y,volName);
%     rtn=textscan(volName,'x%dy%dz%d_s%d_%d_%d_e%d_%d_%d');
%     st=double([rtn{4} rtn{5} rtn{6}]);
%     off=floor((st-1-offInVoxels0)/mipFactor);
%     off2=ceil((st-1-offInVoxels0)/mipFactor);
%     if (off~=off2)
%         fprintf('diff!!\n');
%     end
%     if any(off<0)
%         fprintf('  out of data bound. skipping\n');
%         continue;
%     end

% end

end


function [lstVolLett lstSegInVol] = getSegments( home )

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


function [offset]=getOffsetFromBox( box )

global sizeChunk    
offset = (box(1:3) - [1 0 0]).*sizeChunk + 18;

end