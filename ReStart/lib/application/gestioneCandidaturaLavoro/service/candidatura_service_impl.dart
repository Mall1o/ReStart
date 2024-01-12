import 'package:restart_all_in_one/model/entity/utente_DTO.dart';

import '../../../model/dao/annuncio_di_lavoro/annuncio_di_lavoro_DAO.dart';
import '../../../model/dao/annuncio_di_lavoro/annuncio_di_lavoro_DAO_impl.dart';
import '../../../model/dao/autenticazione/utente/utente_DAO.dart';
import '../../../model/dao/autenticazione/utente/utente_DAO_impl.dart';
import '../../../model/dao/candidatura_lavoro/candidatura_DAO.dart';
import '../../../model/dao/candidatura_lavoro/candidatura_DAO_impl.dart';
import '../../../model/entity/candidatura_DTO.dart';
import 'candidatura_service.dart';

class CandidaturaServiceImpl implements CandidaturaService {
  final AnnuncioDiLavoroDAO _annuncioDiLavoroDAO;
  final UtenteDAO _utenteDAO;
  final CandidaturaDAO _candidaturaDAO;

  CandidaturaServiceImpl()
      : _utenteDAO = UtenteDAOImpl(),
        _annuncioDiLavoroDAO = AnnuncioDiLavoroDAOImpl(),
        _candidaturaDAO = CandidaturaDAOImpl();

  @override
  Future<String> candidatura(String username, int? idLavoro) async {
    UtenteDTO? utente = await _utenteDAO.findByUsername(username);

    if (utente == null)
      return "Utente non trovato"; // non è stato possibile trovare l'utente

    if (await _annuncioDiLavoroDAO.existById(idLavoro!) == false)
      return "Lavoro non esistente"; // il lavoro già esiste

    if (await _candidaturaDAO.existCandidatura(utente.id, idLavoro))
      return "Candidatura esistente"; // la candidatura già esiste

    CandidaturaDTO candidaturaDTO =
        CandidaturaDTO(id_lavoro: idLavoro, id_utente: utente.id);

    if (await _candidaturaDAO.add(candidaturaDTO))
      return "Candidatura effettuata";

    return "fallito";
  }

  @override
  Future<List<UtenteDTO>> listaCandidati(int idLavoro) {
    return _candidaturaDAO.findCandidati(idLavoro);
  }
}
