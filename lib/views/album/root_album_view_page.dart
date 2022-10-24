import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/albums.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/components/scroll_widgets/album_grid_view.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/utils/localizations.dart';

import '../../components/appbars/root_search_app_bar.dart';
import '../image/image_search_view_page.dart';
import 'album_view_page.dart';

class RootAlbumViewPage extends StatefulWidget {
  const RootAlbumViewPage({
    Key? key,
    this.albumId = 0,
    this.isAdmin = false,
  }) : super(key: key);

  static const String routeName = '/';
  final int albumId;
  final bool isAdmin;

  @override
  State<RootAlbumViewPage> createState() => _RootAlbumViewPageState();
}

class _RootAlbumViewPageState extends State<RootAlbumViewPage> {
  final ScrollController _scrollController = ScrollController();

  late final Future<ApiResult<List<AlbumModel>>> _albumsFuture;
  List<AlbumModel> _albumList = [];

  @override
  void initState() {
    super.initState();
    _albumsFuture = fetchAlbums(widget.albumId);
  }

  @override
  dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final ApiResult<List<AlbumModel>> result = await fetchAlbums(widget.albumId);
    if (!result.hasData) {
      return;
    }
    setState(() {
      _albumList = result.data!;
    });
  }

  Future<void> _onAddAlbum() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        backgroundColor: Theme.of(context).cardColor,
        color: Theme.of(context).primaryColor,
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              RootSearchAppBar(
                scrollController: _scrollController,
                onSearch: () {
                  Navigator.of(context).pushNamed(ImageSearchViewPage.routeName);
                },
              ),
              SliverToBoxAdapter(
                child: _albumGrid,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _speedDial,
    );
  }

  Widget get _albumGrid {
    return FutureBuilder<ApiResult<List<AlbumModel>>>(
      future: _albumsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          ApiResult<List<AlbumModel>> result = snapshot.data!;
          if (result.hasError) {
            return Center(
              child: Text(appStrings.categoryImageList_noDataError),
            );
          }
          _albumList = result.data!;
          if (_albumList.isEmpty)
            return Center(
              child: Text(appStrings.categoryMainEmpty),
            );
          return AlbumGridView(
            albumList: _albumList,
            onTap: (album) {
              Navigator.of(context).pushNamed(AlbumViewPage.routeName, arguments: {
                'isAdmin': widget.isAdmin, // todo: use preferences
                'album': album,
              });
            },
          );
        }
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget? get _speedDial {
    if (!widget.isAdmin) return null;
    return FloatingActionButton(
      onPressed: _onAddAlbum,
      child: Icon(Icons.create_new_folder, color: Theme.of(context).primaryColorLight),
    );
  }
}
