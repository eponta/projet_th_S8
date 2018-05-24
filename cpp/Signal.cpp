//Signal.cpp
#include "Signal.h"
#include <vector>
#include <complex>

using namespace std;

vector<std::complex<double>> tronc(vector<std::complex<double>> buffer, int i, int j)
{
	vector<std::complex<double>> tronc;
	for (int k=i;k<=j;k++)
	{
		tronc.push_back(buffer[k]);
	}
	return tronc;
}

Signal::Signal()
{
};


Signal::_corrDetectMax(vector<std::complex<double>> spc_c,int N,int Nsync,int n,int l)
{
	for(int i=0 ;i<spc_c.size()-n-l;i++ ) 
	{
		vector<std::complex<double>> buffer = spc_c
	}
};