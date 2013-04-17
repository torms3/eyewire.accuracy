#include <iostream>
#include <fstream>
#include <stdint.h>
#include <mex.h>

using namespace std;

struct OmMSTEdge 
{
    uint32_t number;
    uint32_t node1ID;
    uint32_t node2ID;
    double threshold;
    uint8_t userJoin;
    uint8_t userSplit;
    uint8_t wasJoined; // transient state
};

extern "C" void mexFunction(int nlhs, mxArray *plhs[],
      int nrhs, const mxArray *prhs[]);

void mexFunction(int nlhs, mxArray *plhs[],
      int nrhs, const mxArray *prhs[])
{
	const char* mstPath = mxArrayToString(prhs[0]);
	ifstream mst(mstPath,ios::binary|ios::ate);

	if( mst )
	{
		int fileSize = mst.tellg();	
		char buf[fileSize];
		mst.seekg(0,ios::beg);
		mst.read(buf,sizeof(buf));	
		mst.close();

		OmMSTEdge* data = reinterpret_cast<OmMSTEdge*>(buf);
				
		int ndim = 1;
		int nEdges = fileSize/sizeof(OmMSTEdge);
		int dims[2] = {nEdges,1};
		int nfields = 4;
		const char* fieldnames[] = {"number","node1ID","node2ID","threshold"};
		mxArray* output = mxCreateStructArray(ndim,dims,nfields,fieldnames);

		for( int i = 0; i < nEdges; ++i )
		{
			mxSetField(output,i,"number",mxCreateDoubleScalar(data[i].number));
			mxSetField(output,i,"node1ID",mxCreateDoubleScalar(data[i].node1ID));
			mxSetField(output,i,"node2ID",mxCreateDoubleScalar(data[i].node2ID));
			mxSetField(output,i,"threshold",mxCreateDoubleScalar(data[i].threshold));
		}

		plhs[0] = output;
	}
}