import os
import uuid
import io
from fastapi import APIRouter, File, UploadFile, HTTPException, Depends
from app.core.deps import get_current_user
from PIL import Image

router = APIRouter(prefix="/uploads", tags=["System Uploads"])

# Directory context
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))
UPLOAD_PATH = os.path.join(BASE_DIR, "static_uploads")

# Ensure it exists physically immediately on import
os.makedirs(UPLOAD_PATH, exist_ok=True)

@router.post("")
async def upload_asset(
    file: UploadFile = File(...),
    current_user = Depends(get_current_user)
):
    """Secured binary conduit to save rich dynamic media assets with auto-compression."""
    # Verify mime types
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Only rich media images allowed")
        
    ext = os.path.splitext(file.filename)[1].lower()
    if not ext:
        ext = ".jpg"
    unique_name = f"{uuid.uuid4()}{ext}"
    save_to = os.path.join(UPLOAD_PATH, unique_name)
    
    try:
        file_content = await file.read()
        img = Image.open(io.BytesIO(file_content))
        
        # Support 4K Ultra-HD hero banner uploads up to 3840px with near-lossless max quality (95%)
        max_size = 3840
        if img.width > max_size or img.height > max_size:
            img.thumbnail((max_size, max_size), Image.Resampling.LANCZOS)
            
        fmt = 'JPEG' if ext in ('.jpg', '.jpeg') else ('PNG' if ext == '.png' else 'JPEG')
        if fmt == 'JPEG' and img.mode in ('RGBA', 'P'):
            img = img.convert('RGB')
            
        if fmt == 'PNG':
            img.save(save_to, fmt, optimize=True)
        else:
            img.save(save_to, fmt, quality=95, optimize=True)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to process and compress file stream: {str(e)}")
    finally:
        file.file.close()
        
    return {"url": f"/static_uploads/{unique_name}"}
