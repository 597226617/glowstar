# GlowStar API Documentation

Base URL: `http://localhost:8080/api`

## Authentication
All `/api/*` endpoints require JWT token in `Authorization: Bearer <token>` header.

## Endpoints

### Auth
| Method | Path | Description |
|--------|------|-------------|
| POST | `/auth/wechat` | WeChat login |
| POST | `/auth/phone` | Phone + SMS login |
| POST | `/auth/google` | Google OAuth |
| POST | `/auth/facebook` | Facebook OAuth |
| POST | `/auth/email` | Email + password login |
| GET | `/auth/session` | Validate session |

### Users
| Method | Path | Description |
|--------|------|-------------|
| GET | `/users/{id}` | Get user profile |
| PUT | `/users/{id}` | Update profile |
| PUT | `/users/{id}/avatar` | Upload avatar |
| GET | `/users/{id}/level` | Get user level & XP |

### Posts / Feed
| Method | Path | Description |
|--------|------|-------------|
| GET | `/posts?tab=recommend&limit=20&offset=0` | Feed (recommend/follow/nearby/study) |
| POST | `/posts` | Create post |
| GET | `/posts/{id}` | Get post detail |
| POST | `/posts/{id}/like` | Like post |
| POST | `/posts/{id}/comment` | Comment on post |

### Voice Rooms
| Method | Path | Description |
|--------|------|-------------|
| GET | `/voice/rooms` | List active rooms |
| POST | `/voice/rooms` | Create room |
| POST | `/voice/rooms/{id}/join` | Join room |
| POST | `/voice/rooms/{id}/leave` | Leave room |

### Chat / Conversations
| Method | Path | Description |
|--------|------|-------------|
| GET | `/conversations` | List conversations |
| GET | `/conversations/{id}/messages` | Get messages |
| WebSocket | `/ws/conversations` | Real-time messaging |

### Matching
| Method | Path | Description |
|--------|------|-------------|
| GET | `/matching/daily` | Get daily matches (max 10) |
| GET | `/matching/profiles/{id}` | Get match profile |
| POST | `/matching/{id}/like` | Like a match |
| POST | `/matching/{id}/pass` | Skip a match |

### Notifications
| Method | Path | Description |
|--------|------|-------------|
| GET | `/notifications` | List notifications |
| PUT | `/notifications/{id}/read` | Mark as read |

### Interests
| Method | Path | Description |
|--------|------|-------------|
| GET | `/interests` | List all interest tags |
| PUT | `/users/{id}/interests` | Update user interests |

### Search
| Method | Path | Description |
|--------|------|-------------|
| GET | `/search?q=keyword&type=users|posts|groups` | Global search |

## Database
20 tables: users, sessions, posts, comments, post_likes, voice_rooms, voice_participants, conversations, messages, user_levels, achievements, user_achievements, daily_tasks, ratings, interest_tags, user_interests, notifications, reports, blob_storage, audit_log.
