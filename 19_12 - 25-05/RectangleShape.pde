public class RectangleShape extends Shape {
  RectangleShape(float x, float y) {
    super(x, y);
  }

  @Override
    protected void drawSpecificShape() {
    //draw the rectangle centered at (0,0)
    rect(-size, -size/2, size*2, size);
  }

  @Override
    protected void drawSelectionOutline() {
    rect(-size, -size/2, size*2, size);
  }

  @Override
    public boolean isMouseOverShape (float mx, float my) {
    pushMatrix();
    translate(x, y);
    rotate(radians(rotation));
    //Inverse transformation of mouse coordinates
    float transformedMx = (mx - x) * cos(radians(-rotation)) - (my - y) * sin(radians(-rotation));
    float transformedMy = (mx - x) * sin(radians(-rotation)) + (my - y) * cos(radians(-rotation));
    popMatrix();


    //check if the transformed mouse coordinates are within the rectangle's bounds
    float halfWidth = size;
    float halfHeight = size /2;
    return transformedMx > -halfWidth && transformedMx < halfWidth && transformedMy > -halfHeight && transformedMy < halfHeight;
  }
}
