
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_news_app/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_news_app/Model/model.dart';

Future<List<Articles>> fetchArticlesBySource(String source) async{

  final response = await http.get('https://newsapi.org/v2/top-headlines?sources=${source}&apiKey=bbd5df3e11f24a64bf61f5bf853be33c');

  if(response.statusCode ==200){

    List articles  = json.decode(response.body)['articles'];
    return articles.map((article)=> new Articles.fromJson(article)).toList();
  }
  else{

    throw Exception('failed to load Articles list');

  }
}

class ArticleScreen extends StatefulWidget{

  final Source source;

  ArticleScreen({Key key, @required this.source}):super(key:key);

  @override
  State<StatefulWidget> createState() => ArticleScreenState();



}

class ArticleScreenState extends State<ArticleScreen>{



  var list_articles;
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    // TODO: implement initState
    refereshListArticle();
  }

  Future<Null> refereshListArticle() async{

    refreshKey.currentState?.show(atTop: false);

    setState(() {

      list_articles = fetchArticlesBySource(widget.source.id);

    });

    return null;


  }


  @override
  Widget build(BuildContext context) {

    // TODO: implement build

    return MaterialApp(

      title: 'flutter news Articles',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: Scaffold(
            appBar: AppBar(title:Text(widget.source.name),

              leading:  IconButton(

                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),

              ),



            ),
            body: Center(



             child: RefreshIndicator(

                key: refreshKey,
                child: FutureBuilder<List<Articles>>(

                future: list_articles,
                builder: (context,snapshot){

                if(snapshot.hasError){

                return Text('Error: ${snapshot.error}');
                }
                else if(snapshot.hasData){

                      List<Articles> articles  = snapshot.data;
                            return new ListView(


                            children: articles.map((article) => GestureDetector(

                                    onTap: (){

                                                _launchUrl(widget.source.url);
                                    },

                            child: Card(

                            elevation: 2.0,
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 14.0),
                            child: Row(

                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                            Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3.0),
                            width:100.0,
                            height: 140.0,
                            child: article.urlToImage != null ? Image.network(article.urlToImage): Image.asset('assets/news.png'),

                            ),

                            Expanded(

                            child: Column(

                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                            Row(

                            children: <Widget>[

                            Expanded(

                            child: Container(

                            margin: const EdgeInsets.only(left:8.0,top: 20.0,bottom: 10.0),
                            child: Text('${article.title}', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),



                            ),

                            ),

                            ],

                            ),


                            Container(

                              margin: const EdgeInsets.only(left:8.0),

                            child: Text('${article.description}', style: TextStyle(color: Colors.grey ,fontSize: 12.0, fontWeight: FontWeight.bold ),),

                            ),

                              Container(

                                margin: const EdgeInsets.only(left:8.0, top: 10, bottom: 10),

                                child: Text('Published At: ${article.publishedAt}', style: TextStyle(color: Colors.black12 ,fontSize: 12.0, fontWeight: FontWeight.bold ),),

                              ),





                            ],

                            ),

                            )

                            ],

                            ),

                            ),

                            )).toList());


                            }



                return CircularProgressIndicator();

},

            ),
            onRefresh: refereshListArticle,

      ),
    ),
      ),

    );





  }

   _launchUrl(String url) async {

    if(await canLaunch(url)){

      await launch(url);

    }else{

      throw {'couldnt able to launch ${url}'};
    }

   }





}