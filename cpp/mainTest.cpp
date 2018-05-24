//mainTest.cpp

#include "header.h"
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

int main()
{

	std::vector<std::complex<double>> spc_c;
	spc_c = {1,2,3,4,5,6};
	vector<std::complex<double>> test;
	test = tronc(spc_c,1,3);
	for(int i=0;i<spc_c.size();i++)
	{
		cout << spc_c[i] << endl;
	}
	for(int i=0;i<test.size();i++)
	{
		cout << test[i] << endl;
	}
}