from app.integraciones.mapas import MapasSimulados


def test_acepta_coordenadas_en_rango():
    resultado = MapasSimulados().validar(-33.45, -70.66)
    assert resultado.valida is True
    assert "Latitud" in resultado.referencia


def test_rechaza_coordenadas_fuera_de_rango():
    mapas = MapasSimulados()
    assert mapas.validar(120, -70.66).valida is False
    assert mapas.validar(-33.45, 200).valida is False
