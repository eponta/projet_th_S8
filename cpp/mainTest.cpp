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

std::complex<double> vectMultiplication(std::vector<std::complex<double>> vect1,std::vector<std::complex<double>> vect2)
{
	std::complex<double> test=0;
	if(vect1.size()==vect2.size()){
		for(int i=0;i<vect1.size();i++)
		{
			test+=vect1[i]*vect2[i];
		}
	}
	else
		cout<<"erreur taille"<<endl;
	return test;
}

int maxIndice(vector<std::complex<double>> buffer)
{
	std::complex<double> max=0;
	int indice=0;
	for(int i=0;i<buffer.size();i++)
	{
		if(real(max)<=real(buffer[i]))
		{
			max=buffer[i];
			indice = i;
		}
	}
	return indice;
}

vector<int> _corrDetectMax(vector<std::complex<double>> spc_c,int N, int Nsync,int n,int l)
{
	std::vector<std::complex<double>> eps;
	vector<int> pos_max_pratique;
	for(int i=0 ;i<spc_c.size()-n-l+1;i++ ) 
	{
		vector<std::complex<double>> buffer = tronc(spc_c, i, i+n+l-1);
		std::complex<double> test=vectMultiplication(tronc(buffer,0,l-1),tronc(buffer,n,n+l-1));
		std::complex<double> epsilon= (std::abs(test)*std::abs(test))/(vectMultiplication(tronc(buffer,0,l-1),tronc(buffer,0,l-1))*vectMultiplication(tronc(buffer,n-1,n+l-1),tronc(buffer,n-1,n+l-1)));
		eps.push_back(epsilon);
		// for(int j=0; j<eps.size();j++)
		// {
		// 	cout<< eps[j]<< endl;

		// }
		// cout << eps.size()<<endl;
		// cout << endl;
	}
	for(int i=0;i<N+Nsync-1;i++)
	{
		vector<std::complex<double>> buffer_max;
		buffer_max = tronc(eps,i*(n+l),(i+1)*(n+l)-1);
		pos_max_pratique.push_back(maxIndice(buffer_max)+(i*(n+l)));
	}
	return pos_max_pratique;
};

vector<double> calc_offset(vector<int> pos_max_pratique, int N, int Nsync, int n, int l)
{
	double sum = 0;
	vector<double> offset_pratique;
	vector<double> moy;
	vector<double> erreur;
	for(int i=0;i<N+Nsync;i++)
	{
		erreur.push_back(pos_max_pratique[i]-(i*(n+l)));
		sum+=erreur[i];
		moy.push_back(sum/(i+1));
		offset_pratique.push_back(erreur[i]);
	}
}

vector<double> moyenne_offset(vector<double> offset_pratique, int N, int Nsync, int n_moy_offset)
{
	vector<double> offset_moy;
	double sum =0;
	for(int i=0;i<n_moy_offset;i++)
	{
		sum+=offset_pratique[i];
		offset_moy.push_back(round(sum/n_moy_offset));
	}
	for(int i=n_moy_offset;i<N+Nsync)
	{
		sum=0;
		for(int j=0;j<n_moy_offset-1;j++)
		{
			sum+=offset_pratique(i-j);
		}
		offset_moy.push_back(round(sum/n_moy_offset));
	}
}


vector<std::complex<double>> supp_cp(vector<std::complex<double>> spc_c, vector<int> pos_max, int N, int Nsync, int n, int l)
{
	int cpt=0;
	for(int i =0;i<N+Nsync;i++)
	{

	}
}

int main()
{
	int N=3;
	int n_moy_offset=1;
	int Nsync=0;
	int n=10;
	int l=2;
	vector<double> offset_pratique;
	vector<double> offset_moy;
	std::vector<std::complex<double>> spc_c {1,1,0.56,0.56,0.46,0.656,0.65,0.45,0.46,0.46,1,1,1,1,0.45,0.32,0.84,0.1,0.4,0.23,0.45,0.45,1,1,1,1,0.45,0.32,0.84,0.1,0.4,0.23,0.45,0.45,1,1};
	vector<int> pos_max_pratique = _corrDetectMax(spc_c,N,Nsync,n,l);
	offset_pratique = calc_offset(pos_max_pratique, N, Nsync, n, l);
	offset_moy=moyenne_offset(offset_pratique,N,Nsync,n_moy_offset);
	for(int i=0; i<pos_max_pratique.size();i++)
	{
		cout<< pos_max_pratique[i]<< endl;;
	}
}