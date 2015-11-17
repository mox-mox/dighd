#include <iostream>
#include <iomanip>
#include <vector>


/**
 *  Linear feedback shift register.
 */
struct Lfsr
{
	std::vector < bool > &data;
	std::vector < bool > taps;
	Lfsr(std::vector < bool > &initial, const std::vector < unsigned int > &taps) : data(initial), taps(data.size(), false)
	{
		for(auto& i : taps)
		{
			this->taps[this->taps.size()-i] = true;
		}
	}

	void iterate()
	{
		bool do_invert = data.back();
		for(int i=data.size()-1; i; i--)
		{
			data[i] = taps[i] ? data[i-1]^do_invert : data[i-1];
		}
		data[0] = do_invert;
	}

	void print()
	{
		std::cout<<"[ ";
		for(auto i : data)
		{
			std::cout<<i;
		}
		std::cout<<" ]"<<std::endl;
	}

	bool d_out()
	{
		return data.back();
	}

	std::vector < bool > sequence(unsigned int length)
	{
		std::vector < bool > seq;
		for(unsigned int i=0; i < length; i++)
		{
			seq.push_back(d_out());
			iterate();
		}
		return seq;
	}

	void dump_taps()
	{
		std::cout<<"Taps: [ 1";
		//for(unsigned int i=1; i<taps.size()-1;i++)
		for(unsigned int i=taps.size()-1; i;i--)
		{
			std::cout<<taps[i]<<"";
		}
		std::cout<<"1 ]"<<std::endl;
	}





};






int main()
{
	std::vector < bool > initial {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1};
	Lfsr lfsr(initial, {46, 23, 15, 12});

	//std::vector < bool > initial {0,0,0,0,0,0,0,0,0,1};
	//Lfsr lfsr(initial, {5});

	lfsr.dump_taps();
	std::cout<<std::endl<<std::endl;

	for(int i=0; i<100; i++)
	{
		std::cout<<"Iteratrion "<<std::setw(3)<<i<<":";
		lfsr.print();
		lfsr.iterate();
	}

	//auto seq = lfsr.sequence(100);
	////for(auto i : seq)
	//for(unsigned int i=seq.size(); i; i--)
	//{
	//		std::cout<<seq[i-1];
	//}
	//std::cout<<std::endl;

	return 0;
}
