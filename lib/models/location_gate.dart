import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationGate {
  static const double raioPermitidoMetros = 30.0;

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

  static bool estaDentroDoRaio({
    required Position posicaoAtual,
    required GeoPoint localizacaoFase,
    double raio = raioPermitidoMetros,
  }) {
    return distanciaMetros(
          posicaoAtual: posicaoAtual,
          localizacaoFase: localizacaoFase,
        ) <=
        raio;
  }
}
