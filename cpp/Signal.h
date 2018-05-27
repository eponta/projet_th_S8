//Signal.h
#include <vector>
#include <complex>
using namespace std;

class Signal
{
	public:
		Signal();
		static std::vector<std::complex<double>> _corrDetectMax(std::vector<std::complex<double>> spc_c,int n,int l);
	private:

};