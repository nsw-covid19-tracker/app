import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:nsw_covid_tracker/home/bloc/home_bloc.dart';
import 'package:nsw_covid_tracker/home/common/consts.dart';
import 'package:nsw_covid_tracker/home/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _panelController = PanelController();
  final _scrollController = ScrollController();
  final _panelMinHeight = 80.0;
  late final HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = context.read<HomeBloc>()..add(FetchAll());
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await AwesomeDialog(
        context: context,
        animType: AnimType.SCALE,
        dialogType: DialogType.INFO,
        dismissOnBackKeyPress: false,
        dismissOnTouchOutside: false,
        width: MediaQuery.of(context).size.width >= kPhoneWidth
            ? kDialogWebWidth
            : null,
        body: Padding(
          padding: kLayoutPadding,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text:
                  'This app is no longer maintained. For official NSW COVID-19 '
                  'case locations map, please visit the ',
              style: Theme.of(context).textTheme.bodyText1,
              children: <TextSpan>[
                TextSpan(
                  text: 'NSW Government website',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _launchURL(
                        'https://www.nsw.gov.au/covid-19/nsw-covid-19-case-locations-map',
                      );
                    },
                ),
                TextSpan(
                  text: '.',
                ),
              ],
            ),
          ),
        ),
      ).show();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state.status == HomeStatus.success) {
            if (state.isEmptyActiveCases) {
              _showNoActiveCasesDialog();
              _homeBloc.add(EmptyActiveCasesHandled());
            } else if (state.isSortCases && _panelController.isAttached) {
              _panelController.open();
              _homeBloc.add(SortCasesHandled());
            }

            if (state.isShowDisclaimer) {
              _showDisclaimerDialog();
              _homeBloc.add(DisclaimerHandled());
            }
          }
        },
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < kPhoneWidth) {
                return _buildMobileLayout(state);
              } else {
                return _buildWebLayout(state);
              }
            },
          );
        },
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: constraints.maxWidth < kPhoneWidth ? _panelMinHeight : 0,
            ),
            child: FilterButton(),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(HomeState state) {
    return SlidingUpPanel(
      controller: _panelController,
      minHeight: _panelMinHeight,
      maxHeight: MediaQuery.of(context).size.height * 0.8,
      collapsed: state.status == HomeStatus.success
          ? CollapsedPanel(controller: _panelController)
          : LoadingPanel(),
      panelBuilder: (sc) => Panel(panelSc: sc),
      onPanelOpened: () => _homeBloc.add(DisableMap()),
      onPanelClosed: () => _homeBloc.add(EnableMap()),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: _panelMinHeight),
            child: MapView(
              scrollController: _scrollController,
              onMapTap: () {
                if (_panelController.isPanelOpen) _panelController.close();
              },
            ),
          ),
          SearchBar(
            scrollController: _scrollController,
            onSearchBarTap: () {
              if (_panelController.isPanelOpen) _panelController.close();
            },
          ),
          if (state.status == HomeStatus.success)
            Align(
              alignment: Alignment.bottomLeft,
              child: _buildDataUpdatedAt(
                state.formattedUpdatedAt,
                bottomPadding: _panelMinHeight + 24,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWebLayout(HomeState state) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: state.status == HomeStatus.success
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: CasesListView(dialogSc: _scrollController),
                )
              : Center(child: LoadingWidget()),
        ),
        Expanded(
          flex: 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              MapView(
                scrollController: _scrollController,
              ),
              SearchBar(
                scrollController: _scrollController,
              ),
              if (state.status == HomeStatus.success)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: _buildDataUpdatedAt(
                    state.formattedUpdatedAt,
                    leftPadding: 4.0,
                    bottomPadding: 24.0,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataUpdatedAt(String updatedAt,
      {leftPadding = 8.0, bottomPadding = 0.0}) {
    return Container(
      margin: EdgeInsets.only(left: leftPadding, bottom: bottomPadding + 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Last Updated: $updatedAt',
        style: Theme.of(context).textTheme.caption?.apply(color: Colors.white),
      ),
    );
  }

  void _showNoActiveCasesDialog() {
    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.INFO,
      width: MediaQuery.of(context).size.width >= kPhoneWidth
          ? kDialogWebWidth
          : null,
      title: 'No active cases found',
      desc: 'Keep maintaining social distancing and '
          'wear a mask when physical distancing is not possible.',
    ).show();
  }

  void _showDisclaimerDialog() {
    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.INFO,
      width: MediaQuery.of(context).size.width >= kPhoneWidth
          ? kDialogWebWidth
          : null,
      body: Padding(
        padding: kLayoutPadding,
        child: _DisclaimerBody(),
      ),
    ).show();
  }
}

class _DisclaimerBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Disclaimer', style: Theme.of(context).textTheme.headline6),
        WidgetPaddingSm(),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'The NSW COVID-19 case locations are processed from ',
            style: Theme.of(context).textTheme.bodyText1,
            children: <TextSpan>[
              TextSpan(
                text: 'Data.NSW',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _launchURL('https://data.nsw.gov.au/'),
              ),
              TextSpan(
                text:
                    ' and presented as is. Note that cases on public transport '
                    'are not presented on the app.\n\nFor official news and '
                    'updates on NSW COVID-19, please refer to the ',
              ),
              TextSpan(
                text: 'NSW Government website',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _launchURL('https://www.nsw.gov.au/covid-19/'
                      'latest-news-and-updates'),
              ),
              TextSpan(
                text: '.\n\nThis app is',
              ),
              TextSpan(
                text: ' NOT ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: 'affiliated with the NSW Government in any way, and is',
              ),
              TextSpan(
                text: ' NOT ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: 'to be relied on for any purpose or '
                    'for the accuracy of the data.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
