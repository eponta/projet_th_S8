//Signal.h
#include <vector>
#include <complex>
using namespace std;

class Signal
{
	public:
		Signal();
		int _corrDetectMax(std::vector<std::complex<double>> spc_c,int N,int sync,int n,int l);

	private:

};