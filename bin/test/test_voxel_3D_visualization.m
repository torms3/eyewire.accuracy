function test_voxel_3D_visualization()
%% Test information
%
%	task: 49627 (0)
%	volume: x14y07z27 50798
%	seeds:
%	4737 4767 4802 4908 
% 	consensus:
% 	3171 3172 3311 3463 3861 3966 4368 4369 4468 4670 4728 4737 4758 4767 4782 4802 4833 4837 4857 4864 4907 4908 4956 5017 5047 5066 5187 
% 	union:
% 	3171 3172 3311 3463 3861 3966 4368 4369 4468 4670 4728 4737 4758 4767 4782 4802 4833 4837 4857 4864 4907 4908 4956 5017 5047 5066 5187 3255 4133 4278 4323 4644 4666 4669 4731 4754 5105 5124 5126 5233 5236 5268 5360 5722 5896 5919 3075 3128 3144 3252 4929 5214 4786 


%% Test file path
%
root_path = get_project_root_path();
file_path = [root_path '/data/test'];
file_name = 'volume.uint32_t.raw';


%% Read data
%
fp = fopen([file_path '/' file_name],'r');

sizeChunk = [128 128 128];
sizeChunkLinear = prod(sizeChunk);
sizeVolume = [128 128 128];
vol = zeros(sizeVolume,'uint32');
fseek(fp,0,'bof');
vol = reshape(fread(fp,sizeChunkLinear,'*uint32'),sizeChunk);

fclose(fp);


%% 3D visualization
%
c_seg = [3171 3172 3311 3463 3861 3966 4368 4369 4468 4670 4728 4737 4758 4767 4782 4802 4833 4837 4857 4864 4907 4908 4956 5017 5047 5066 5187];
u_seg = [3171 3172 3311 3463 3861 3966 4368 4369 4468 4670 4728 4737 4758 4767 4782 4802 4833 4837 4857 4864 4907 4908 4956 5017 5047 5066 5187 3255 4133 4278 4323 4644 4666 4669 4731 4754 5105 5124 5126 5233 5236 5268 5360 5722 5896 5919 3075 3128 3144 3252 4929 5214 4786];
c_vol = ismember(vol,c_seg);

fp_seg = setdiff(u_seg,c_seg);
fp_vol = ismember(vol,fp_seg);

h = vol3d('cdata',smooth3(c_vol));
% h = vol3d('cdata',c_vol);
view(3);
axis tight;
daspect([1 1 1]);

% hold on;
alpha = 0.2 .* fp_vol;
h = vol3d('cdata',smooth3(fp_vol),'Alpha',alpha);
hold off;

grid on;
colormap bone;

end