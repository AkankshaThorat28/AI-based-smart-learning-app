from pydantic import BaseModel
from typing import Literal, Optional

class UserCreate(BaseModel):
    name: str
    disability_mode: Literal['blind', 'deaf', 'normal']

class UserResponse(BaseModel):
    id: int
    name: str
    disability_mode: str

class FeedbackCreate(BaseModel):
    user_id: int
    feedback_text: str
    rating: int