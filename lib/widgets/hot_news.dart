import 'package:flutter/material.dart';
import 'package:flutter_news_app_19022022/bloc/get_hot_news_bloc.dart';
import 'package:flutter_news_app_19022022/elements/error_element.dart';
import 'package:flutter_news_app_19022022/elements/loader_element.dart';
import 'package:flutter_news_app_19022022/model/article.dart';
import 'package:flutter_news_app_19022022/model/article_response.dart';
import 'package:flutter_news_app_19022022/screens/news_detail.dart';

import 'package:flutter_news_app_19022022/style/theme.dart' as Style;

import 'package:timeago/timeago.dart' as timeago;

class HotNews extends StatefulWidget {
  const HotNews({Key? key}) : super(key: key);

  @override
  _HotNewsState createState() => _HotNewsState();
}

class _HotNewsState extends State<HotNews> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getHotNewsBloc..getHotNews();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ArticleResponse>(
      stream: getHotNewsBloc.subject.stream,
      builder: (context, AsyncSnapshot<ArticleResponse> snapshot){
        if(snapshot.hasData){
          if(snapshot.data!.error != null &&
              snapshot.data!.error.length > 0
          ){
            return buildErrorWidget(snapshot.data!.error);
          }
          return _buildHotNews(snapshot.data!);
        }else if(snapshot.hasError){
          return buildErrorWidget(snapshot.error.toString());
        }else{
          return buildLoadingWidget();
        }
      },
    );
  }

  Widget _buildHotNews(ArticleResponse data) {
    List<ArticleModel> articles = data.articles;
    if (articles.length == 0) {
      return Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "No more news",
              style: TextStyle(color: Colors.black45),
            ),

          ],
        ),
      );
    } else {
      return Container(
        height: articles.length / 2 * 210.0,
        padding: EdgeInsets.all(5.0),
        child: new GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: articles.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.85),
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.only(
                    left: 5.0,
                    right: 5.0,
                    top: 10.0
                ),

                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>NewsDetail(article: articles[index])));
                  },
                  child: Container(
                    width: 220.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: 5.0,
                              spreadRadius: 1.0,
                              offset: Offset(1.0, 1.0)
                          )
                        ]
                    ),
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5.0),
                                    topRight: Radius.circular(5.0)
                                ),
                                image: DecorationImage(
                                    image: checkImgIsNull(articles[index].img),
                                  fit: BoxFit.cover
                                )
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 15.0, bottom: 15.0
                          ),
                          child: Text(
                            articles[index].title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                              height: 1.3,
                              fontSize: 15.9
                            ),
                          ),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                left: 10.0,
                                right: 10.0
                              ),
                              width: 180.0,
                              height: 1.0,
                              color: Colors.black12,
                            ),
                            Container(
                              width: 30.0,
                              height: 3.0,
                              color: Style.Colors.mainColor,
                            )
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                articles[index].source.name,
                                style: TextStyle(
                                  color: Style.Colors.mainColor,
                                  fontSize: 9.0
                                ),
                              ),
                              Text(
                                timeAgo(DateTime.parse(articles[index].date)),
                                style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: 9.0
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
        ),
      );
    }
  }

  ImageProvider checkImgIsNull(String imgURL){
    if(imgURL == null){
      return AssetImage("assets/img/placeholder.jpg");
    }else{
      return NetworkImage(imgURL);
    }
  }

  String timeAgo(DateTime date){
    return timeago.format(date, allowFromNow: true, locale: "en");
  }

}
