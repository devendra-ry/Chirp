import 'package:blogging_app/models/blogpost.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/shared/loading.dart';
import 'package:blogging_app/views/comments.dart';
import 'package:blogging_app/views/create_comment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share/share.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';

class ArticlePage extends StatefulWidget {
  final String? userId;
  final String? blogPostId;
  final String? postImage;

  const ArticlePage({
    Key? key,
    required this.userId,
    required this.blogPostId,
    this.postImage,
  }) : super(key: key);

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  BlogPost? _blogPostDetails;
  bool _isLoading = true;
  bool _isLiked = false;
  bool _isDisliked = false;
  bool _isFavourite = false;
  DocumentReference? _blogPostRef;
  DocumentSnapshot? _blogPostSnap;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchBlogPostDetails();
  }

  Future<void> _fetchBlogPostDetails() async {
    try {
      // Fetch blog post details
      _blogPostDetails = await DatabaseService(uid: widget.userId)
          .getBlogPostDetails(widget.blogPostId);

      if (_blogPostDetails != null) {
        // Get blog post reference and snapshot
        _blogPostRef = FirebaseFirestore.instance
            .collection('blogPosts')
            .doc(widget.blogPostId);
        _blogPostSnap = await _blogPostRef?.get();

        if (_blogPostSnap != null && _blogPostSnap!.exists) {
          final data = _blogPostSnap!.data() as Map<String, dynamic>?;

          if (data != null) {
            // Check liked status
            final likedBy = data['likedBy'] as List<dynamic>? ?? [];
            _isLiked = likedBy.contains(widget.userId);

            // Check disliked status
            final dislikedBy = data['dislikedBy'] as List<dynamic>? ?? [];
            _isDisliked = dislikedBy.contains(widget.userId);

            // Check favourite status
            _isFavourite = data['favourite'] == true;
          }
        } else {
          debugPrint("Blog post document does not exist.");
        }

        // Get user data
        final userRes = await DatabaseService(uid: widget.userId)
            .getUserDataID(widget.userId);
        if (userRes.docs.isNotEmpty) {
          _userName = (userRes.docs[0].data() as Map<String, dynamic>)['fullName']
              ?.toString();
        } else {
          debugPrint("User data not found for user ID: ${widget.userId}");
        }
      } else {
        debugPrint("Blog post not found.");
      }
    } catch (e) {
      debugPrint('Error getting blog post details: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper method to toggle like/dislike
  Future<void> _toggleInteraction({
    required bool isLiking,
    required VoidCallback updateState,
  }) async {
    try {
      if (isLiking) {
        await DatabaseService(uid: widget.userId)
            .togglingLikes(widget.blogPostId);
      } else {
        await DatabaseService(uid: widget.userId)
            .togglingDisLikes(widget.blogPostId);
      }

      _blogPostSnap = await _blogPostRef?.get();
      updateState();
    } catch (e) {
      debugPrint('Error toggling interaction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return _isLoading
        ? const Loading()
        : Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(154, 183, 211, 1.0),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _blogPostDetails?.blogPostTitle ??
              '', // Safe access with null-aware operator
          style: const TextStyle(
              fontFamily: 'OpenSans', color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePost(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            // Post Image
            _buildPostImage(height),

            // Post Content Container
            _buildPostContentContainer(context, height),
          ],
        ),
      ),
    );
  }

  // Image display widget
  Widget _buildPostImage(double height) {
    return Container(
      constraints: BoxConstraints.expand(height: height * 0.3),
      child: Image.network(
        widget.postImage ??
            '', // Use the provided postImage or an empty string if null
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error); // Show an error icon if image loading fails
        },
      ),
    );
  }

  // Post content container widget
  Widget _buildPostContentContainer(BuildContext context, double height) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 200.0, 16.0, 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Post Title
          Text(
            _blogPostDetails?.blogPostTitle ?? '',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 10.0),

          // Post Metadata
          Text(
            "${_blogPostDetails?.date ?? ''} By ${_blogPostDetails?.blogPostAuthor ?? ''}",
          ),

          const SizedBox(height: 10.0),
          const Divider(),
          const SizedBox(height: 10.0),

          // Interaction Buttons
          _buildInteractionRow(context),

          const SizedBox(height: 10.0),

          // Post Content
          Text(
            _blogPostDetails?.blogPostContent ?? '',
            textAlign: TextAlign.justify,
          ),

          const SizedBox(height: 5.0),

          // Comment Button
          _buildCommentButton(context),
        ],
      ),
    );
  }

  // Interaction buttons row
  Widget _buildInteractionRow(BuildContext context) {
    return Row(
      children: <Widget>[
        // Like Button
        _buildInteractionButton(
          icon: Icons.thumb_up,
          isActive: _isLiked,
          count: _blogPostSnap?.get('likedBy')?.length ?? 0,
          onTap: () => _toggleInteraction(
            isLiking: true,
            updateState: () {
              setState(() {
                _isLiked = !_isLiked;
                if (_isLiked) _isDisliked = false;
              });
            },
          ),
        ),

        // Dislike Button
        _buildInteractionButton(
          icon: Icons.thumb_down,
          isActive: _isDisliked,
          count: _blogPostSnap?.get('dislikedBy')?.length ?? 0,
          onTap: () => _toggleInteraction(
            isLiking: false,
            updateState: () {
              setState(() {
                _isDisliked = !_isDisliked;
                if (_isDisliked) _isLiked = false;
              });
            },
          ),
        ),

        const SizedBox(width: 16.0),

        // Comments Icon
        _buildCommentsIcon(context),

        const SizedBox(width: 5.0),

        // Favorite Button
        _buildFavoriteButton(),
      ],
    );
  }

  // Comments icon widget
  Widget _buildCommentsIcon(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Comments(
              userId: widget.userId,
              blogPostId: widget.blogPostId,
            ),
          ),
        );
      },
      child: const Icon(Icons.comment),
    );
  }

  // Favorite button widget
  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: () async {
        setState(() {
          _isFavourite = !_isFavourite;
        });

        try {
          if (_isFavourite) {
            await DatabaseService(uid: widget.userId)
                .addFavourite(_blogPostDetails?.blogPostId);
          } else {
            await DatabaseService(uid: widget.userId)
                .removeFavourite(_blogPostDetails?.blogPostId);
          }
        } catch (e) {
          debugPrint('Error toggling favorite: $e');
          // Revert the state if operation fails
          setState(() {
            _isFavourite = !_isFavourite;
          });
        }
      },
      child: Icon(
        Icons.favorite,
        color: _isFavourite ? Colors.pinkAccent : null,
        size: 17.0,
      ),
    );
  }

  // Comment button widget
  Widget _buildCommentButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 5.0,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreateComment(
              userId: widget.userId,
              userName: _userName,
              blogPostId: widget.blogPostId,
            ),
          ),
        );
      },
      child: const Text(
        'Comment',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'OpenSans',
        ),
      ),
    );
  }

  // Interaction button widget
  Widget _buildInteractionButton({
    required IconData icon,
    required bool isActive,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color: isActive ? Colors.pinkAccent : null,
              size: 17.0,
            ),
            const SizedBox(width: 20.0),
            Text(
              '$count',
              style: const TextStyle(fontSize: 13.0),
            ),
          ],
        ),
      ),
    );
  }

  // Share method
  void _sharePost(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;

    try {
      await Share.share(
        "${_blogPostDetails?.blogPostTitle ?? ''} - ${_blogPostDetails?.blogPostContent ?? ''}",
        subject: _blogPostDetails?.blogPostContent ?? '',
        sharePositionOrigin:
        box?.localToGlobal(Offset.zero) & (box?.size ?? const Size.zero),
      );
    } catch (e) {
      debugPrint('Error sharing post: $e');
    }
  }
}