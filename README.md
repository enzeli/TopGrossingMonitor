TopGrossingMonitor
==================

Key Features
- Fetch designated RSS feed and display in tableview.
- Store favourites in Core Data, managed by Singleton FavDataManager class. ( Modified version of [here](http://nachbaur.com/blog/smarter-core-data) )
- Universal app supporting both landscape and portrait orientation on iPad.

External Resources Used
- SDWebImage: nice image asynchronous loading and caching library.
- Some free icon/image files from Internet.

Known problems
- "Go to app store" Button does not work on iOS simulator due to forbidden service.
- Long strings get truncated in detail view.

Potential future Work
- App Detail View is underdesigned.
- Handle long string displaying in labels
- Adding more transition animation could make UX more friendly, especially on iPad.
- Expand Core Data functionality. Currently images are not stored, and data is store in unstructured raw form.