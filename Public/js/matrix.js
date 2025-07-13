document.addEventListener('DOMContentLoaded', () => {
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    canvas.id = 'matrixCanvas';
    document.body.prepend(canvas);
    
    // Set canvas to window size
    const resizeCanvas = () => {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
    };
    resizeCanvas();
    window.addEventListener('resize', resizeCanvas);

    // Matrix characters
    const chars = "01アァカサタナハマヤャラワガザダバパイィキシチニヒミリヰギジヂビピウゥクスツヌフムユュルグズブヅプエェケセテネヘメレヱゲゼデベペオォコソトノホモヨョロヲゴゾドボポヴッンABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const charArray = chars.split("");
    
    // 3D effect parameters
    const baseFontSize = 14;
    const fontSizeRange = 10;
    const columns = Math.ceil(canvas.width / baseFontSize);
    
    // Each column drops from a random starting point
    const drops = [];
    for (let i = 0; i < columns; i++) {
        drops[i] = {
            y: Math.floor(Math.random() * canvas.height / baseFontSize) * -1,
            speed: 0.5 + Math.random() * 1.5,
            fontSize: baseFontSize + Math.random() * fontSizeRange,
            scale: 0.8 + Math.random() * 0.4
        };
    }

    // Matrix colors with depth variation
    const depthColors = [
        {color: [15, 240, 15], opacity: 0.15},   // Far (dim green)
        {color: [10, 200, 10], opacity: 0.4},    // Medium
        {color: [13, 230, 13], opacity: 0.7},    // Close
        {color: [12, 255, 12], opacity: 1}       // Very close (bright green)
    ];
    
    function drawMatrix() {
        // Darker overlay for better contrast
        ctx.fillStyle = 'rgba(0, 0, 0, 0.08)';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        
        for (let i = 0; i < drops.length; i++) {
            const char = charArray[Math.floor(Math.random() * charArray.length)];
            const drop = drops[i];
            const x = i * baseFontSize;
            const y = drop.y * baseFontSize;
            
            // Determine depth layer
            const depth = Math.min(3, Math.floor((drop.fontSize - baseFontSize) / (fontSizeRange / 4)));
            const colorInfo = depthColors[depth];
            
            // Apply perspective transformation
            ctx.save();
            ctx.translate(x, y);
            ctx.scale(drop.scale, drop.scale);
            
            ctx.font = `${drop.fontSize}px monospace`;
            ctx.fillStyle = `rgba(${colorInfo.color[0]}, ${colorInfo.color[1]}, ${colorInfo.color[2]}, ${colorInfo.opacity})`;
            
            // Draw character
            ctx.fillText(char, 0, 0);
            ctx.restore();
            
            // Move drops at different speeds
            drop.y += drop.speed;
            
            // Reset drops that reach bottom
            if (y > canvas.height * 1.5) {
                drop.y = -20;
                drop.fontSize = baseFontSize + Math.random() * fontSizeRange;
                drop.speed = 0.5 + Math.random() * 1.5;
                drop.scale = 0.8 + Math.random() * 0.4;
            }
        }
        
        requestAnimationFrame(drawMatrix);
    }

    drawMatrix();
});