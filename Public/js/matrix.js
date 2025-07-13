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

    // Matrix characters with more variety
    const chars = "01アァカサタナハマヤャラワガザダバパイィキシチニヒミリヰギジヂビピウゥクスツヌフムユュルグズブヅプエェケセテネヘメレヱゲゼデベペオォコソトノホモヨョロヲゴゾドボポヴッンABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const charArray = chars.split("");
    
    // 3D effect parameters
    const baseFontSize = 14;
    const fontSizeRange = 10;
    const columns = canvas.width / baseFontSize;
    
    // Each column drops from a random starting point
    const drops = [];
    for (let i = 0; i < columns; i++) {
        drops[i] = {
            y: Math.floor(Math.random() * canvas.height / baseFontSize),
            speed: 0.5 + Math.random() * 1.5,
            fontSize: baseFontSize + Math.random() * fontSizeRange,
            scale: 0.8 + Math.random() * 0.4
        };
    }

    // Matrix colors with depth variation
    const depthColors = [
        {color: '#0F0', opacity: 0.15},
        {color: '#0A0', opacity: 0.4},
        {color: '#0D0', opacity: 0.7},
        {color: '#0C0', opacity: 1}
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
            
            // Determine depth layer (0-3) based on font size
            const depth = Math.min(3, Math.floor((drop.fontSize - baseFontSize) / (fontSizeRange / 4)));
            const colorInfo = depthColors[depth];
            
            // Apply perspective transformation
            ctx.save();
            ctx.translate(x, y);
            ctx.scale(drop.scale, drop.scale);
            
            ctx.font = `${drop.fontSize}px monospace`;
            
            // Fixed color calculation
            const r = parseInt(colorInfo.color.slice(1, 3), 16);
            const g = parseInt(colorInfo.color.slice(3, 5), 16);
            const b = parseInt(colorInfo.color.slice(5, 7), 16);
            ctx.fillStyle = `rgba(${r}, ${g}, ${b}, ${colorInfo.opacity})`;
            
            // Draw character with depth-based offset
            ctx.fillText(char, 0, 0);
            ctx.restore();
            
            // Move drops at different speeds
            drop.y += drop.speed;
            
            // Reset drops that reach bottom + random reset
            if (y > canvas.height && Math.random() > 0.97) {
                drop.y = 0;
                drop.fontSize = baseFontSize + Math.random() * fontSizeRange;
                drop.speed = 0.5 + Math.random() * 1.5;
                drop.scale = 0.8 + Math.random() * 0.4;
            }
        }
    }

    setInterval(drawMatrix, 50);
});