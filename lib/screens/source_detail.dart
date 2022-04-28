import 'package:flutter/material.dart';
import 'package:flutter_news_app_19022022/bloc/get_source_news_bloc.dart';
import 'package:flutter_news_app_19022022/elements/error_element.dart';
import 'package:flutter_news_app_19022022/elements/loader_element.dart';
import 'package:flutter_news_app_19022022/model/article.dart';
import 'package:flutter_news_app_19022022/model/article_response.dart';
import 'package:flutter_news_app_19022022/model/source.dart';

import 'package:flutter_news_app_19022022/style/theme.dart' as Style;

import 'package:timeago/timeago.dart' as timeago;

import 'news_detail.dart';

class SourceDetail extends StatefulWidget {
  final SourceModel source;
  const SourceDetail({Key? key, required this.source}) : super(key: key);

  @override
  _SourceDetailState createState() => _SourceDetailState(source);
}

class _SourceDetailState extends State<SourceDetail> {
  final SourceModel source;
  _SourceDetailState(this.source);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSourceNewsBloc..getSourceNews(source.id);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    getSourceNewsBloc..drainStream();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: AppBar(
          elevation: 0.0,
          backgroundColor: Style.Colors.mainColor,
          title: Text(""),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              left: 15.0,
              right: 15.0,
              bottom: 15.0
            ),
            color: Style.Colors.mainColor,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Hero(
                    tag: source.id,
                    child: SizedBox(
                      height: 80.0,
                      width: 80.0,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2.0,
                            color: Colors.white
                          ),
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage("assets/logos/${source.id}.png"),
                            fit: BoxFit.cover
                          )
                        ),
                      ),
                    )
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  source.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  source.description,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0
                  ),
                )
              ],
            ),
          ),
          Expanded(
              child: StreamBuilder<ArticleResponse>(
                stream: getSourceNewsBloc.subject.stream,
                builder: (context, AsyncSnapshot<ArticleResponse> snapshot){
                  if(snapshot.hasData){
                    if(snapshot.data!.error != null &&
                        snapshot.data!.error.length > 0
                    ){
                      return buildErrorWidget(snapshot.data!.error);
                    }
                    return _buildSourceNews(snapshot.data!);
                  }else if(snapshot.hasError){
                    return buildErrorWidget(snapshot.error.toString());
                  }else{
                    return buildLoadingWidget();
                  }
                },
              )
          )
        ],
      ),
    );
  }

  Widget _buildSourceNews(ArticleResponse data){
    List<ArticleModel> articles = data.articles;
    if(articles.length == 0){
      return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "No Articles"
            )
          ],
        ),
      );
    }else{
      return ListView.builder(
          itemCount: articles.length,
        itemBuilder: (context, index){
            return GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>NewsDetail(article: articles[index])));
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey,
                      width: 1.0
                    )
                  ),
                  color: Colors.white
                ),
                height: 150.0,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.0),
                      width: MediaQuery.of(context).size.width *3 / 5,
                      child: Column(
                        children: [
                          Text(
                            articles[index].title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 14.0
                            ),
                          ),
                          Expanded(
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      timeAgo(DateTime.parse(articles[index].date)),
                                      style: TextStyle(
                                          color: Colors.black26,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10.0
                                      ),
                                    ),

                                  ],
                                ),
                              ))
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          right: 10.0
                      ),
                      width: MediaQuery.of(context).size.width*2/5,
                      height: 130.0,
                      child: FadeInImage.assetNetwork(
                        placeholder: "assets/img/placeholder.jpg",
                        image: articles[index].img == null ? "https://media.istockphoto.com/vectors/thumbnail-image-vector-graphic-vector-id1147544807?k=20&m=1147544807&s=612x612&w=0&h=pBhz1dkwsCMq37Udtp9sfxbjaMl27JUapoyYpQm0anc="
                        : articles[index].img,
                        // image: checkImgIsNull(articles[index].img),
                        fit: BoxFit.fitHeight,
                        width: double.maxFinite,
                        height: MediaQuery.of(context).size.height * 1 /3,
                      ),
                    )

                  ],
                ),
              ),

            );
        },
      );
    }
  }

  String timeAgo(DateTime date){
    return timeago.format(date, allowFromNow: true, locale: 'en');
  }

  // ImageProvider checkImgIsNull(String imgURL){
  //   if(imgURL == null){
  //     return AssetImage("assets/img/placeholder.jpg");
  //   }else{
  //     return NetworkImage(imgURL);
  //   }
  // }

}
