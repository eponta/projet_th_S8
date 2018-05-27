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

vector<std::complex<double>> vectMultiplication(vect1, vect2)
{
	double test=0;
	for(int i=0;i<vect1.size();i++)
	{
		test+=vect1[i]*vect2[i];
	}
	return test;
}

Signal::Signal()
{
};


Signal::_corrDetectMax(vector<std::complex<double>> spc_c,int n,int l)
{
	vector<std::complex<double>> eps;
	for(int i=0 ;i<spc_c.size()-n-l;i++ ) 
	{
		vector<std::complex<double>> buffer = tronc(spc_c, i, i+n+l-1);
		double test=vectMultiplication(tronc(buffer,0,l-1),tronc(buffer,n-1,n+l-1));
		double epsilon= std::pow(std::abs(test),2)/(vectMultiplication(tronc(buffer,0,l-1),tronc(buffer,1,l-1))*vectMultiplication(tronc(buffer,n-1,n+l-1),tronc(buffer,n-1,n+l-1)));
		eps[i]=epsilon;
	}
};