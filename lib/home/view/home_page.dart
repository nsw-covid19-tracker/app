import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:nsw_covid_tracker/home/bloc/home_bloc.dart';
import 'package:nsw_covid_tracker/home/common/consts.dart';
import 'package:nsw_covid_tracker/home/repo/repo.dart';
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
  HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = context.bloc<HomeBloc>()..add(FetchAll());
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
          if (state is HomeSuccess) {
            if (state.isEmptyActiveCases) {
              _showNoActiveCasesDialog();
              _homeBloc.add(EmptyActiveCasesHandled());
            } else if (state.isSortCases) {
              _panelController.open();
              _homeBloc.add(SortCasesHandled());
            } else if (state.selectedCase != null) {
              CaseDialog.show(context, _scrollController, state.selectedCase);
              _homeBloc.add(ShowCaseHandled());
            }

            if (state.isShowDisclaimer) {
              _showDisclaimerDialog();
              _homeBloc.add(DisclaimerHandled());
            }
          }
        },
        builder: (context, state) {
          var isLoading = true;
          var cases = <Case>[];

          if (state is HomeSuccess) {
            isLoading = false;
            cases = state.casesResult;
          }

          return SlidingUpPanel(
            controller: _panelController,
            minHeight: _panelMinHeight,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            collapsed: isLoading
                ? LoadingPanel()
                : CollapsedPanel(controller: _panelController),
            panelBuilder: (sc) => Panel(
              panelSc: sc,
              panelController: _panelController,
              cases: cases,
            ),
            body: Stack(
              fit: StackFit.expand,
              children: [
                MapWidget(
                  scrollController: _scrollController,
                  panelController: _panelController,
                  cases: cases,
                ),
                SearchBar(
                  onSearchBarTap: () => _panelController.close(),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: _panelMinHeight),
        child: FilterButton(),
      ),
    );
  }

  void _showNoActiveCasesDialog() {
    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.INFO,
      title: 'No active cases found',
      desc: 'Keep maintaining social distancing and '
          'wear a mask when physical distancing is not possible',
    )..show();
  }

  void _showDisclaimerDialog() {
    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.INFO,
      body: Padding(
        padding: kLayoutPadding,
        child: _DisclaimerBody(),
      ),
    )..show();
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
                text: ' and presented as is.\n\nFor official news and updates '
                    'on NSW COVID-19, please refer to the ',
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
              TextSpan(text: '.')
            ],
          ),
        )
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
