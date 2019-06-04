# states_rebuilder

A Flutter state management solution that allows you: 
  * to separate your User Interface (UI) representation from your logic classes
  * to easily control how your widgets rebuild to reflect the actual state of your application.
  * to inject depencies using Injector 


### For State Management see this [Medium Article](https://medium.com/flutter-community/widget-perfect-state-management-in-flutte-is-it-possible-73e76c205620)
### For Dependency Injection and more elaborate State Management architecture see [this example](https://github.com/GIfatahTH/states_rebuilder-using-Dane-Mackier-Implementation-Guide).

This Library provides Four classes and two methods:

  * The `StatesRebuilder` class. Your logics classes (viewModels) will extend this class to create your own business logic BloC (equally can be called ViewModel or Model).
  * The `rebuildStates` method. You call it inside any of your logic classes that extends `StatesRebuilder`. It rebuilds all the mounted 'StateBuilder' widgets. It can filter the widgets to rebuild by tag.
  this is the signature of the `rebuildState`:
  ```dart
  rebuildStates([List<dynamic> tags])
  ```
  * The `StateBuilder` Widget. You wrap any part of your widgets with it to add it to listeners list of your logic classes and hence can rebuild it using `rebuildState` method
  this is the constructor of the `StateBuilder`:
  
  ```dart
  StateBuilder( {
      Key key, 
      dynamic tag, // you define the tag of the state. This is the first way. You can provide a list of tags.
      List<StatesRebuilder> viewModels, // You give a list of the logic classes (BloC) you want this widget to listen to.
      @required (BuildContext, String) → Widget builder,
      (BuildContext, String) → void initState, // for code to be executed in the initState of a StatefulWidget
      (BuildContext, String) → void dispose, // for code to be executed in the dispose of a StatefulWidget
      (BuildContext, String) → void didChangeDependencies, // for code to be executed in the didChangeDependencies of a StatefulWidget
      (BuildContext, String, StateBuilder) → void didUpdateWidget // for code to be executed in the didUpdateWidget of a StatefulWidget
    });
  ```
  `tag` is of type dynmaic. It can be String (for small projects) or enum member (enums are preferred for big projects).When a list of dynamic tags is provided, states_rebuilder consider it as many tags and will rebuild this widget if any of theses tags are invoked by the `rebuildStates` method.

 * To extands the state with mixin (practical case is animation), use `StateWithMixinBuilder`
```Dart
StateWithMixinBuilder<T>( {
      Key key, 
      dynamic tag, // you define the tag of the state. This is the first way
      List<StatesRebuilder> viewModels, // You give a list of the logic classes (BloC) you want this this widget to listen to.
      @required (BuildContext, String) → Widget builder, 
      @required (BuildContext, String,T) → void initState, // for code to be executed in the initState of a StatefulWidget
      @required (BuildContext, String,T) → void dispose, // for code to be executed in the dispose of a StatefulWidget
      (BuildContext, String,T) → void didChangeDependencies, // for code to be executed in the didChangeDependencies of a StatefulWidget
      (BuildContext, String,StateBuilder, T) → void didUpdateWidget // for code to be executed in the didUpdateWidget of a StatefulWidget,
      (String, AppLifecycleState) → void didChangeAppLifecycleState // 
      @required MixinWith mixinWith
});
```
  Avaibable mixins are: singleTickerProviderStateMixin, tickerProviderStateMixin, AutomaticKeepAliveClientMixin and WidgetsBindingObserver.
* With `rebuildFromStreams` method you can control the rebuild of many widgets from single subscription StreamController. You can listen to many streams, merge them and combine them.
```dart
rebuildFromStreams<T>({
  // Inputs
  List<Stream<T>> streams, //You define a list of streams or
  List<StreamController<T>> controllers, // a list of controllers
  List<T> initialData, // List of initialdate. the order of the list is the same as in controller or stream list.
  List<dynamic> tags, // List of tags of widgets to rebuild when streams has data
  List<StreamTransformer> transforms, // list of transform to apply on streams.

  // Outputs
  (List<AsyncSnapshot<T>>) → void snapshots, //List of snapshots in the same order as in streams list
  (AsyncSnapshot<T>) → void snapshotMerged, // The merged snapshot of all the streams.
  (AsyncSnapshot<T>) → void snapshotCombined, // The combined snapshot. the combination function is given in `combine` closuer.
  (List<AsyncSnapshot<T>>) → Object combine // The combination function.
}) 
```

  * `BlocProvider` widget. Used to provide your BloCs
  ```dart
   BlocProvider<YourBloc>({
     CounterBloc bloc
     Widget child,
   })
  ```

  * Injector widget as dependency injection:
  to register model and services use Injector the same way you use BlocProvider
  ```dart
  Injector({
    List<() → dynamic> models, // List of models to register
    (BuildContext) → Widget builder, 
    () → void dispose, // a custom method to call when Injector is disposed.
    bool disposeModels: false // Whether Injector will automatically call dispose method from the registered models.
  }) 
  ```
  To get the same instance of the model inside any class use:
  ```dart 
  Injector.get<T>([String name]).
  ``` 
  Where T is the type of the model and name is optional used if you want to call a named model.

  To get a new instance of the model, you  use:
  ```dart 
  Injector.getNew<T>([String name]).
  ``` 
  Model are automatically unregistered when the injector is disposed.

  You can declare many Injectors where you want in the widget tree.

## Prototype Example for dependency injection

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      models: [
        () => ModelA(),
        () => ModelB(),
        () => ModelC(Injector.get<ModelA>()),// Directy inject ModelA in ModelC construtor
        () => ModelD(),
       // () => ModelD(),// Not allowed. Model can be registered only once.
        () => [ModelD(),"costumName"], // To register many model of the same type use this approach
        ],
      builder: (_) => MyWidget(),
    );
  }

  // You can get your models from any class provided it is registered before calling it.
  class MyWidget extends StatelessWidget {

    final modelA = Injector.get<ModelA>();
    final modelA1 = Injector.getNew<ModelA>();
    final modelD = Injector.get<ModelD>();
    final modelDNamed = Injector.get<ModelD>("costumName");


    @override
    Widget build(BuildContext context) {
      return Injector(
        models: [
          () => ModelF(),
        ],
      builder: (_) => AnotherWidget(),
      )
    }
  }
  ```




## Prototype Example for state management

your_bloc.dart file:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:states_rebuilder/states_rebuilder.dart'

  // enum is preferred over String to name your `tag` for big projects.
  // The nume of the enum is of your choice. You can have many enums.

  // -- Conventionally for each of your BloCs you define a corresponding enum.
  // -- For very large projects you can make all your enums in a single file.
  enum YourState {yourtag1};

  class YourViewModel extends StatesRebuilder{

      var yourVar;

      /// You have two ways:

      /// ************** First way: (tag way) **************

      yourMethod1() {
        // some logic staff;
        yourVar = yourNewValue;
        rebuildStates([YourState.yourtag1]);
      }

      // example of fetching data and rebuilding widgets after obtaining the data
      fetchData1() async {
        await yourRepository.fetchDate();
        rebuildStates([YourState.yourtag1]);
      }

      /// ************** Second way (tag way) **************

      yourMethod2(String tagID) {
        // some logic staff;
        yourVar = yourNewValue;
        rebuildStates([tagID]);
      }

      // example of fetching data and rebuild widgets after obtaining the data
      fetchData2(String tagID) async {
        await yourRepository.fetchDate();
        rebuildStates([tagID]);
      }

      /// ************** Combination of first and second ways **************

      yourMethod3(String tagID) {
        // some logic staff;
        yourVar = yourNewValue;
        rebuildStates([tagID, YourState.yourtag1]);
      }


      /// ************** Rebuild All **************
      yourMethod4() {
        // some logic staff;
        yourVar = yourNewValue;
         // `rebuildStates()` with no parameter: All widgets that are wrapped with
         //`StateBuilder` will rebuild to reflect the new counter value.
         // You get a similar behavior like in ``scoped_model`` or ``provider`` packages

        rebuildStates();
      }
  }
  ```
your main.dart file:

```dart
  // ************** First way: (tag way) ************** 
  class Firstway extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Column(
            children: <Widget> [
              StateBuilder(
                tag : YourState.yourtag1 // you can use just a String "yourtag1",
                viewModels : [yourVM],
                initState: (_)=> yourBloc.fetchData1(),
                builder: (_) => YourChildWidget(yourBloc.yourVar),
            ),
            RaisedButton(
              child: Text("first way"),
              onPressed : yourBloc.yourMethod1,
            )
          ],
      );
    }
  }

    // ************** Second way: (tag way) ************** 
    class Secondway extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return StateBuilder(
              initState: yourBloc.fetchData2,
              builder: (String tagID) => Column(
                    children: <Widget> [
                      YourChildWidget(yourBloc.yourVar),
                      RaisedButton(
                        child: Text("Second way"),
                        onPressed :yourBloc.yourMethod2(tagID),
                      ), 
                    ],
                  ),
              );
    }
  }
```
