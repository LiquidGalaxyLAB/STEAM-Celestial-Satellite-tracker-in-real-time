import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/cubit/satellite_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/models/satellite_model.dart';

import '../repositories/countries_iso.dart';
import '../repositories/satellite_repository.dart';

class SatelliteCubit extends Cubit<SatelliteState> {
  SatelliteCubit() : super(SatelliteLoadingState()) {
    fetchData();
  }

  SatelliteRepository satelliteRepository = SatelliteRepository();
  late List<SatelliteModel> _satellites;

  void fetchData() async {

    try {
      List<SatelliteModel> satellites = await satelliteRepository.fetchData();
      List iso = ISO().iso;
      for (int i = 0; i < satellites.length; i++) {
        String countries = satellites[i].countries.toString();
        List _countries = countries.split(',');
        if (satellites[i].countries.toString() != 'null' ||
            satellites[i].countries.toString() != '') {
          for (int j = 0; j < iso.length; j++) {
            Map<String, String> data = iso[j];
            for (int k = 0; k < _countries.length; k++) {
              if (data['Code'] == _countries[k]) {
                _countries[k] = data['Name'];
              }
            }
          }
        }
        satellites[i].countries = '';
        if (_countries.length == 1) {
          satellites[i].countries = satellites[i].countries! + _countries[0];
        } else {
          for (int l = 0; l < _countries.length; l++) {
            satellites[i].countries =
                '${satellites[i].countries! + _countries[l]},';
          }
        }
      }
      _satellites = satellites;
      emit(SatelliteLoadedState(satellites));
    } on DioError catch (e) {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        emit(SatelliteErrorState('Check your internet connection!'));
      } else {
        emit(SatelliteErrorState(e.type.toString()));
      }
    }
  }

  Future<void> filterSearchData(String filterText, String country, String status, bool decayed, bool launched, bool deployed) async {

    List<SatelliteModel> filteredList = _satellites;
    filteredList = filteredList.where((data) =>
    data.name!.toLowerCase().contains(filterText.toLowerCase()) ||
        data.noradCatId.toString().toLowerCase().contains(filterText.toLowerCase()) ||
        data.satId!.toLowerCase().contains(filterText.toLowerCase()))
        .toList();
    if(country!='ALL'){
      filteredList = filteredList.where((data) =>
          data.countries.toString().toLowerCase().contains(country.toLowerCase()))
          .toList();
    }
    if(status!='ALL'){
      filteredList = filteredList.where((data) =>
          data.status.toString().toLowerCase().contains(status.toLowerCase()))
          .toList();
    }
    if(decayed==true){
      filteredList = filteredList.where((data) =>
      data.decayed.toString()!='null')
          .toList();
    }
    if(launched==true){
      filteredList = filteredList.where((data) =>
      data.launched.toString()!='null')
          .toList();
    }
    if(deployed==true){
      filteredList = filteredList.where((data) =>
      data.deployed.toString()!='null')
          .toList();
    }

    emit(FilteredSatelliteState(filteredList));

  }

}