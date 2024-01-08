import 'dart:async';

import '../../../model/dao/autenticazione/CA/ca_DAO.dart';
import '../../../model/dao/autenticazione/CA/ca_DAO_impl.dart';
import '../../../model/dao/evento/evento_DAO.dart';
import '../../../model/dao/evento/evento_DAO_impl.dart';
import '../../../model/entity/evento_DTO.dart';
import 'evento_service.dart';

class EventoServiceImpl implements EventoService {
  final EventoDAO _eventoDAO;
  final CaDAO _caDAO;

  EventoServiceImpl()
      : _eventoDAO = EventoDAOImpl(),
        _caDAO = CaDAOImpl();

  EventoDAO get eventoDAO => _eventoDAO;
  CaDAO get caDAO => _caDAO;

  @override
  Future<bool> addEvento(EventoDTO e) async {
    return _eventoDAO.add(e);
  }

  @override
  Future<bool> deleteEvento(int id) {
    return _eventoDAO.removeById(id);
  }
/*
  @override
  Future<EventoDTO?> detailsEvento(int id) {
    return _eventoDAO.findById(id);
  }*/

  @override
  Future<List<EventoDTO>> communityEvents() {
    return _eventoDAO.findAll();
  }

  @override
  Future<bool> modifyEvento (EventoDTO e) {
    return _eventoDAO.update(e);
  }

  @override
  Future<bool> approveEvento(EventoDTO e) async {
    if(await _eventoDAO.existById(e.id) == false){
      return false;
    }
    e.approvato = true;
    return _eventoDAO.update(e);
  }

  @override
  Future<List<EventoDTO>> eventiPubblicati(String usernameCa) {
    return _eventoDAO.findByApprovato(usernameCa);
  }

  @override
  Future<bool> rejectEvento(EventoDTO e) async {
    if(await _eventoDAO.existById(e.id) == false){
      return false;
    }
    return _eventoDAO.removeById(e.id);
  }
}
