
import '../../../model/entity/utente_DTO.dart';

abstract class CandidaturaService {

  Future<String> candidatura(String username, int? idLavoro);
  Future<List<UtenteDTO>> listaCandidati(int idLavoro);

}
