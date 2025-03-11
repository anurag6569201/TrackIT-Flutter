import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class Post {
  final int id;
  final String authorImage;
  final String content;
  final int author;
  final List<int> likes;
  final String authorName;

  Post({
    required this.id,
    required this.authorImage,
    required this.content,
    required this.author,
    required this.likes,
    required this.authorName,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      authorImage: json['author_image'],
      content: json['content'],
      author: json['author'],
      likes: List<int>.from(json['likes']),
      authorName: json['author_name'],
    );
  }
}

class Comment {
  final int id;
  final String authorImage;
  final String authorName;
  final String text;
  final String createdAt;
  final int post;
  final int author;

  Comment({
    required this.id,
    required this.authorImage,
    required this.authorName,
    required this.text,
    required this.createdAt,
    required this.post,
    required this.author,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      authorImage: json['author_image'],
      authorName: json['author_name'],
      text: json['text'],
      createdAt: json['created_at'],
      post: json['post'],
      author: json['author'],
    );
  }
}

class PostsList extends StatefulWidget {
  const PostsList({super.key});

  @override
  State<PostsList> createState() => _PostsListState();
}

class _PostsListState extends State<PostsList> {
  final String baseUrl = 'http://172.22.0.37:8000';
  List<Post> posts = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/sphere/view/'));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          posts = jsonResponse.map((post) => Post.fromJson(post)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (error) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Failed to load posts'),
            ElevatedButton(
              onPressed: fetchPosts,
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchPosts,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => PostCard(post: posts[index], baseUrl: baseUrl),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final Post post;
  final String baseUrl;

  const PostCard({super.key, required this.post, required this.baseUrl});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _showComments = false;
  List<Comment> _comments = [];
  bool _isLoadingComments = false;
  final TextEditingController _commentController = TextEditingController();
  bool _isLiking = false;

  Future<void> _fetchComments() async {
    setState(() => _isLoadingComments = true);
    
    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/api/sphere/comments/${widget.post.id}/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() => _comments = data.map((c) => Comment.fromJson(c)).toList());
      }
    } finally {
      setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _toggleLike() async {
    if (_isLiking) return;
    
    setState(() => _isLiking = true);
    final userId = 1; // Replace with actual user ID from auth
    
    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/api/sphere/like/${widget.post.id}/'),
        body: {'user_id': userId.toString()},
      );

      if (response.statusCode == 200) {
        setState(() {
          if (widget.post.likes.contains(userId)) {
            widget.post.likes.remove(userId);
          } else {
            widget.post.likes.add(userId);
          }
        });
      }
    } finally {
      setState(() => _isLiking = false);
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;
    
    final userId = 1; // Replace with actual user ID from auth
    final newComment = _commentController.text;
    _commentController.clear();

    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/api/sphere/comments/${widget.post.id}/'),
        body: {
          'text': newComment,
          'author': userId.toString(),
        },
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        setState(() {
          _comments.insert(0, Comment.fromJson(data));
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('MMM d, y • hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAuthorRow(),
            const SizedBox(height: 12),
            Text(widget.post.content, style: Theme.of(context).textTheme.bodyLarge),
            _buildInteractionRow(),
            if (_showComments) _buildCommentsSection(),
            _buildCommentInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage(
            '${widget.baseUrl}${widget.post.authorImage}',
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.post.authorName, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget _buildInteractionRow() {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            widget.post.likes.isEmpty ? Icons.favorite_border : Icons.favorite,
            color: widget.post.likes.isEmpty ? Colors.grey : Colors.red,
          ),
          onPressed: _toggleLike,
        ),
        Text('${widget.post.likes.length} likes'),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.comment),
          onPressed: () => setState(() {
            _showComments = !_showComments;
            if (_showComments) _fetchComments();
          }),
          color: _showComments ? Colors.blue : Colors.grey,
        ),
        Text('comments'),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(top: 0),
          child: _isLoadingComments
              ? const Center(child: CircularProgressIndicator())
              : _comments.isEmpty
                  ? const Text('No comments yet', 
                      style: TextStyle(color: Colors.grey))
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => _buildCommentTile(_comments[index]),
                    ),
        ),
      ],
    );
  }

  Widget _buildCommentTile(Comment comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage('${widget.baseUrl}${comment.authorImage}'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(left: 6,right:6,top:0,bottom: 3), // Added padding for better spacing
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(comment.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                Text(comment.text),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildCommentInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: _addComment,
          ),
        ],
      ),
    );
  }
}