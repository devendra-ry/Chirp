import 'package:blogging_app/models/blogpost.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/shared/loading.dart';
import 'package:blogging_app/views/comments.dart';
import 'package:blogging_app/views/create_comment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

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
  DocumentReference? _blogPostRef;
  DocumentSnapshot? _blogPostSnap;

  @override
  void initState() {
    super.initState();
    _fetchBlogPostDetails();
  }

  Future<void> _fetchBlogPostDetails() async {
    try {
      // Fetch blog post details
      _blogPostDetails = await DatabaseService(uid: widget.userId)
          .getBlogPostDetails(widget.blogPostId!);

      if (_blogPostDetails != null) {
        _blogPostRef = FirebaseFirestore.instance
            .collection('blogPosts')
            .doc(widget.blogPostId);
        _blogPostSnap = await _blogPostRef?.get();

        if (_blogPostSnap != null && _blogPostSnap!.exists) {
          final data = _blogPostSnap!.data() as Map<String, dynamic>?;

          if (data != null) {
            _isLiked = (data['likedBy'] as List<dynamic>? ?? []).contains(widget.userId);
            _isDisliked = (data['dislikedBy'] as List<dynamic>? ?? []).contains(widget.userId);
          }
        } else {
          debugPrint("Blog post document does not exist.");
        }

        final userRes = await DatabaseService(uid: widget.userId).getUserData(widget.userId!);
        if (userRes.docs.isNotEmpty) {
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

  Future<void> _toggleInteraction({
    required bool isLiking,
    required VoidCallback updateState,
  }) async {
    try {
      if (isLiking) {
        await DatabaseService(uid: widget.userId!).toggleLikes(widget.blogPostId!);
      } else {
        await DatabaseService(uid: widget.userId!).toggleDislikes(widget.blogPostId!);
      }

      _blogPostSnap = await _blogPostRef?.get();
      updateState();
    } catch (e) {
      debugPrint('Error toggling interaction: $e');
    }
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required bool isActive,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: isActive ? Colors.blue : Colors.grey),
          const SizedBox(width: 4.0),
          Text('$count'),
        ],
      ),
    );
  }

  Widget _buildCommentsIcon(BuildContext context) {
    final commentCount = (_blogPostSnap?.get('comments') as List<dynamic>?)?.length ?? 0;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Comments(
            blogPostId: widget.blogPostId,
            userId: widget.userId,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.comment, color: Colors.grey),
          const SizedBox(width: 4.0),
          Text('$commentCount'),
        ],
      ),
    );
  }

  Widget _buildPostImage(double height) {
    return Container(
      constraints: BoxConstraints.expand(height: height * 0.3),
      child: Image.network(
        widget.postImage ?? '',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error);
        },
      ),
    );
  }

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
          Text(
            _blogPostDetails?.blogPostTitle ?? '',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10.0),
          Text("${_blogPostDetails?.date ?? ''} By ${_blogPostDetails?.blogPostAuthor ?? ''}"),
          const SizedBox(height: 10.0),
          const Divider(),
          const SizedBox(height: 10.0),
          _buildInteractionRow(context),
          const SizedBox(height: 10.0),
          Text(
            _blogPostDetails?.blogPostContent ?? '',
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 5.0),
          _buildCommentButton(context),
        ],
      ),
    );
  }

  Widget _buildInteractionRow(BuildContext context) {
    return Row(
      children: <Widget>[
        _buildInteractionButton(
          icon: Icons.thumb_up,
          isActive: _isLiked,
          count: (_blogPostSnap?.get('likedBy') as List<dynamic>?)?.length ?? 0,
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
        _buildInteractionButton(
          icon: Icons.thumb_down,
          isActive: _isDisliked,
          count: (_blogPostSnap?.get('dislikedBy') as List<dynamic>?)?.length ?? 0,
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
        _buildCommentsIcon(context),
      ],
    );
  }

  Widget _buildCommentButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateComment(
            blogPostId: widget.blogPostId,
            userId: widget.userId,
          ),
        ),
      ),
      child: const Text('Add Comment'),
    );
  }

  void _sharePost(BuildContext context) {
    final title = _blogPostDetails?.blogPostTitle ?? '';
    final content = _blogPostDetails?.blogPostContent ?? '';

    Share.share(
      '$title\n\n$content',
      subject: 'Check out this blog post!',
    ).catchError((e) {
      debugPrint('Error sharing post: $e');
      return ShareResult('', ShareResultStatus.unavailable); // Return a ShareResult
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return _isLoading
        ? Loading()
        : Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(154, 183, 211, 1.0),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _blogPostDetails?.blogPostTitle ?? '',
          style: const TextStyle(
            fontFamily: 'OpenSans',
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePost(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            _buildPostImage(height),
            _buildPostContentContainer(context, height),
          ],
        ),
      ),
    );
  }
}
