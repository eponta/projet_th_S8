#include <iostream>
#include <complex>

#include <uhd/usrp/multi_usrp.hpp>
#include <uhd/utils/msg.hpp>

using namespace std;

void my_handler(uhd::msg::type_t type, const std::string &msg){
	std::cerr << "UHD: " << type << " : " << msg << std::endl;
}

int main()
{
	auto fc = 1090e6;
	auto fe = 8e6;
	auto N = 100e6;
	auto Np = 1;

	uhd::msg::register_handler(&my_handler);
	std::string usrp_addr("type=usrp1");           // L'adresse de l'USRP est écrite en dur pour l'instant
	uhd::usrp::multi_usrp::sptr usrp;              // Le pointeur vers l'USRP
	usrp = uhd::usrp::multi_usrp::make(usrp_addr); // Initialisation de l'USRP

	usrp->set_rx_rate(fe);                         // Set de la fréquence d'échantillonnage
	usrp->set_rx_freq(fc);                         // Set de la fréquence porteuse
	//usrp->set_rx_subdev_spec(uhd::usrp::subdev_spec_t("AB:0"));
	usrp->set_rx_antenna("RX2");

	uhd::stream_args_t
		stream_args("fc64");        // Type des données à échantillonner (ici complexes float 64 - 32 bits par voie)
	uhd::rx_streamer::sptr rx_stream = usrp->get_rx_stream(stream_args); // Pointeur sur les data reçues

	/*
	 * Affichage de quelques paramètres
	 */
	std::cout << "# " << std::string(50, '-') << std::endl;
	std::cout << "# Let's get started" << std::endl;
	std::cout << "# " << std::string(50, '-') << std::endl;

	usrp->issue_stream_cmd(uhd::stream_cmd_t::STREAM_MODE_START_CONTINUOUS);

	std::cout << "# Sampling Rate set to: " << usrp->get_rx_rate() << std::endl;
	std::cout << "# Central Frequency set to: " << usrp->get_rx_freq() << std::endl;
	std::cout << "# " << std::string(50, '-') << std::endl;
	std::cout << "# Ecoute en cours ..." << std::endl;

	/*
     * Démarrage de l'aquisition
     */
	std::vector<std::complex<double>> buff(N); // Notre buffer à nous dans le programme
	uhd::rx_metadata_t md;                     // Des metadata
	rx_stream->recv(&buff.at(0), 1, md);         // Récupere un échantillon (sinon il est nul)

	for (auto np = 0; np < Np; np++)
	{
		auto num_rx_samps = 0;                     // Nombre d'echantillons reçus
		while (num_rx_samps < buff.size())
			num_rx_samps += rx_stream->recv(&buff.at(num_rx_samps), N - num_rx_samps, md);

		std::cout << "X" << " = [";
		for (auto i = 0; i < buff.size()-1; i++)
			std::cout << buff[i].real() << " + 1i * " << buff[i].imag() << ", ";
		std::cout << buff[buff.size()-1].real() << " + 1i * " << buff[buff.size()-1].imag() << "];" << std::endl;
	}

	usrp->issue_stream_cmd(uhd::stream_cmd_t::STREAM_MODE_STOP_CONTINUOUS);
	rx_stream.reset();
	usrp.reset();
	return 0;
}
