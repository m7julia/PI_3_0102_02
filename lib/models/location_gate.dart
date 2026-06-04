import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationGate {
  static const bool modoApresentacao = true; // para apresentar 

  static const double raioPermitidoMetros = 30.0;

  static bool estaDentroDoRaio({
    required Position? posicaoAtual,
    required GeoPoint localizacaoFase,
    double raio = raioPermitidoMetros,
  }) {
    if (modoApresentacao) return true; // bypassa tudo
    if (posicaoAtual == null) return false;

    return distanciaMetros(
          posicaoAtual: posicaoAtual,
          localizacaoFase: localizacaoFase,
        ) <=
        raio;
  }

  static double distanciaMetros({
    required Position posicaoAtual,
    required GeoPoint localizacaoFase,
  }) {
    return Geolocator.distanceBetween(
      posicaoAtual.latitude,
      posicaoAtual.longitude,
      localizacaoFase.latitude,
      localizacaoFase.longitude,
    );
  }
}
