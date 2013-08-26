#include <stdint.h>
#include "vmmlib/axisAlignedBoundingBox.h"

using namespace std;
using namespace vmml;

typedef uint32_t OmSegID;

struct OmColor {
    uint8_t red;
    uint8_t green;
    uint8_t blue;
};

struct OmSegmentDataV4 {
    OmSegID value;
    OmColor color;
    uint64_t size;
    AxisAlignedBoundingBox<int> bounds;	// 26 bytes    
};



#include <iostream>

void print_segment( OmSegmentDataV4* seg )
{
	// cout << "Seg ID: " << seg->value << endl;
	// cout << "Size: " << seg->size << endl;
	Vector3<int> vMin = seg->bounds.getMin();	
	if( vMin.x < 1 || vMin.y < 1 || vMin.z < 1 )
		cout << "min: " << vMin << endl;
	Vector3<int> vMax = seg->bounds.getMax();
	if( vMax.x > 254 || vMax.y > 254 || vMax.z > 254 )
		cout << "MAX: " << vMax << endl;
	// cout << endl;
}



#include <fstream>
#include <mex.h>

void mexFunction( int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[] )
{
	if( 2 != nrhs )
    {
        // print_usage();
        mexErrMsgTxt("Not enough arguments");
    }

    // metadata file path
    const char* metadataPath = mxArrayToString(prhs[0]);
    ifstream metadata( metadataPath, ios::binary | ios::ate );

    if( metadata )
	{
		int fileSize = metadata.tellg();
		char buf[fileSize];
		metadata.seekg(0,ios::beg);
		metadata.read(buf,sizeof(buf));	
		metadata.close();

		OmSegmentDataV4* data = reinterpret_cast<OmSegmentDataV4*>(buf);

		int nData = fileSize/sizeof(OmSegmentDataV4);
		for( int i = 0; i < nData; ++i )
		{
			OmSegmentDataV4* seg = data + i;
			if( seg->value )
				print_segment( seg );
		}
	}
}