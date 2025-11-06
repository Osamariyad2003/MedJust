import 'package:med_just/features/sidebar/data/data_source/sidebar_data_source.dart';
import 'package:med_just/features/sidebar/data/model/header_model.dart';

class SidebarRepo {
  final SidebarDataSource _dataSource;

  SidebarRepo({SidebarDataSource? dataSource})
    : _dataSource = dataSource ?? SidebarDataSource();

  Future<HeaderModel> getHeader({required String uid}) async {
    return await _dataSource.getHeader(uid: uid);
  }

  Future<void> signOut() async {
    return await _dataSource.signOut();
  }
}
