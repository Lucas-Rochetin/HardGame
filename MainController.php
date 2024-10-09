<?php

class MainController {
    private $apiUrl;
    
    public function __construct($apiUrl) {
        $this->apiUrl = $apiUrl;
    }
    
    private function apiRequest($method, $endpoint, $data = null) {
        $url = $this->apiUrl . $endpoint;
        
        $headers = [
            "Content-Type: application/json",
        ];

        // Initialize cURL
        $ch = curl_init();
        
        if ($data !== null) {
            $data = json_encode($data);  // Encode data to JSON
            curl_setopt($ch, CURLOPT_POSTFIELDS, $data);  // Set the request body
            $headers[] = "Content-Length: " . strlen($data);  // Correct the content length
        }
        
        // Set cURL options
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);  // Set the HTTP method
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);  // Return the response as a string
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);  // Set the headers
        // curl_setopt($ch, CURLOPT_POSTFIELDS,     ["aled" => "javascript"] ); 
        
        // Execute the request
        $result = curl_exec($ch);
        
        // Check for errors
        if ($result === false) {
            return ['error' => 'Request failed: ' . curl_error($ch)];
        }
        
        // Close cURL handle
        curl_close($ch);
        return json_decode($result, true);
    }
    
    
    
    // # this should get api primary information
    public function get_api_status() {
        $response = @file_get_contents($this->apiUrl);
        
        if ($response === FALSE) {
            return 'KO';
        } else {
            $data = json_decode($response, true);
            return isset($data['api_status']) && $data['api_status'] === true ? 'OK' : 'KO';
        }
    }
    
    // # this should get api author
    public function get_api_author() {
        $response = @file_get_contents($this->apiUrl);
        
        if ($response === FALSE) {
            return 'KO';
        } else {
            $data = json_decode($response, true);
            return isset($data['api_author']) ? $data['api_author'] : 'No author defined';
        }
    }
    
    // # this should print the page inside page folder
    public function include_page($page) {
        $sanitized_page = basename($page);
        $filepath = "./page/{$sanitized_page}.phtml";
        
        if (file_exists($filepath)) {
            include $filepath;
        } else {
            echo "<p>Page not found.</p>";
        }
    }
    
    // # this should get all users
    public function get_users() {
        return $this->apiRequest('GET', '/users');
    }
    
    // # this should get a user using his login
    public function get_user_by_login($login) {
        return $this->apiRequest('GET', "/users/$login");
    }
    
    // # this should create a user
    public function create_user($user_data) {
        return $this->apiRequest('POST', '/users', $user_data);
    }
    
    // # this should update a user
    public function update_user($login, $user_data) {
        return $this->apiRequest('PUT', "/users/$login", $user_data);
    }
    
    // # this should add money to a user
    public function add_money($login, $money) {
        return $this->apiRequest('POST', "/users/$login/add_money", ['money' => $money]);
    }
    
    // # this should create all game
    public function get_games() {
        return $this->apiRequest('GET', '/games');
    }
    
    // # this should get a game
    public function get_game_by_name($name) {
        return $this->apiRequest('GET', "/games/$name");
    }
    
    // # this should create a game
    public function create_game($game_data) {
        return $this->apiRequest('POST', '/games', $game_data);
    }
    
    // # this should buy a game for a user
    public function buy_game($login, $game_name) {
        return $this->apiRequest('POST', "/users/$login/buy/$game_name", []);
    }
    
    // # this should get all message of rgps
    public function get_rgpd_message() {
        return $this->apiRequest('GET', "/api/rgpd/message");
    }
    
    // # this should post a message for admin RGPD
    public function post_rgpd_message($message) {
        return $this->apiRequest('POST', '/api/rgpd/add_new_message', [$message]);
    }

    public function connect_user($login, $password) {
        // Send login and password to the API
        // $response = $this->apiRequest('POST', '/api/user/connect', ['login' => $login, 'password' => $password]);
        $response = $this->apiRequest('POST', '/api/user/connect', [
            'login' => $login,
            'password' => $password,
        ]);
        
        // Check if the response indicates successful login
        if (isset($response['status']) && $response['status'] === 'success' && isset($response['user_token'])) {
            // Set the cookie with the token
            setcookie('user_token', $response['user_token'], time() + 3600, '/', '', false, true);
            return true;
        }
    
        return false;
    }
    
    public function verify_token() {
        // Retrieve the user token from the cookie
        if (!isset($_COOKIE['user_token'])) {
            return false;
        }
    
        // Send the token to the API for verification
        $response = $this->apiRequest('POST', '/api/user/verif_token', ['token' => $_COOKIE['user_token']]);
    
        // Check if the response indicates that the token is valid
        if (isset($response['status']) && $response['status'] === 'valid') {
            return true;
        }
    
        return false;
    }
    
}
?>