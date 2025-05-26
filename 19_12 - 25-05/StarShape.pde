public class StarShape extends Shape {
  public StarShape (float x, float y) {
    super(x, y);
  }

  @Override
    public void drawSpecificShape() {
    drawStar(0, 0, size/2, size, 5);
  }
  
  @Override
    protected void drawSelectionOutline() {
    drawStar(0, 0, size/2, size, 5);
  }

  @Override
    public boolean isMouseOverShape(float mx, float my) {
    // For star shapes, accurate hit detection with rotation is complex
    // For simplicity, we used an approximate circular hit detection after inverse transformation.
    pushMatrix();
    translate(x, y);
    rotate(radians(rotation));
    float transformedMx = (mx - x) * cos(radians(-rotation)) - (my - y) * sin(radians(-rotation));
    float transformedMy = (mx - x) * sin(radians(-rotation)) - (my - y) * cos(radians(-rotation));
    popMatrix();
    
    //check if the transformed mouse coordinates are within an approximate circle
    return dist (transformedMx, transformedMy, 0, 0) < size;
  }

  //helper function to draw a star
  private void drawStar(float x, float y, float innerRadius, float outerRadius, int numberPoints) {
    double angle = 2 * Math.PI / numberPoints;
    beginShape();
    for (int i = 0; i < numberPoints; i++) {
      float sx = x + (float)Math.cos(i*angle) * outerRadius;
      float sy = y + (float)Math.sin(i*angle) * outerRadius;
      vertex (sx, sy);
      sx = x + (float)Math.cos((i + 0.5) * angle) * innerRadius;
      sy = y + (float)Math.sin((i + 0.5) * angle) * innerRadius;
      vertex (sx, sy);
    }
    endShape(CLOSE);
  }
}
