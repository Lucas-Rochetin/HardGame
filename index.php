<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HardGame</title>
    <link rel="icon" href="assets/images/favicon.png">
    <link rel="stylesheet" href="assets/css/index.css">
</head>

<?php
    require 'script/MainController.php';
    $controller = new MainController('http://backend:5763/');
?>
<body>
    <h1>Welcome to HardGame App</h1>
    <p>This is the frontend of the application HardGame.</p>
    <div class="status-container">
        <div class="status-item">
            <span class="status-label">API status:</span>
            <span class="status-value">
                <?php 
                    echo $controller->get_api_status();
                ?>
            </span>
        </div>
        <div class="status-item">
            <span class="status-label">API author:</span>
            <span class="status-value">
                <?php 
                    echo $controller->get_api_author();
                ?>
            </span>
        </div>
    </div>


    <div class="dynamic-content">
        <?php
            if (isset($_GET['page'])) {
                $controller->include_page($_GET['page']);
            } else {
                echo "<p>Welcome to the homepage. Select a page to include.</p>";
            }
        ?>
    </div>

    <footer>
        <a href="?page=configs">
        <div class="footer-item">
            <img src="assets/images/configs.png" alt="Configs">
            <span>Configs</span>
        </div>
        </a>
        <a href="?page=game">
        <div class="footer-item">
            <img src="assets/images/game.png" alt="Game">
            <span>Game</span>
        </div>
        </a>
        <a href="?page=user">
        <div class="footer-item">
            <img src="assets/images/user.png" alt="User">
            <span>User</span>
        </div>
        </a>
        <a href="?page=rgpd">
        <div class="footer-item">
            <img src="assets/images/rgpd.png" alt="RGPD">
            <span>RGPD</span>
        </div>
        </a>
        <a href="?page=cookies">
        <div class="footer-item">
            <img src="assets/images/cookies.png" alt="Cookies Policy">
            <span>Cookies Policy</span>
        </div>
        </a>
        <a href="?page=login">
        <div class="footer-item">
            <img src="assets/images/login.png" alt="Login">
            <span>Login</span>
        </div>
        </a>
    </footer>
</body>
</html>
