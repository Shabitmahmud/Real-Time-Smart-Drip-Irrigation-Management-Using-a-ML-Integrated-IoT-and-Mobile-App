<?php
// Database configuration
$host = "localhost";
$dbname = "irrigation";
$username = "root";
$password = "";

// Establish a connection to the MySQL database
$conn = new mysqli($host, $username, $password, $dbname);

// Check if the connection was successful
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} else {
    echo "Connected to the MySQL database.<br>";
}

// Print received POST data
echo "Received POST data:<br>";
foreach ($_POST as $key => $value) {
    echo "$key: $value<br>";
}

// Check if values were sent by NodeMCU
if (!empty($_POST['sendval1']) && !empty($_POST['sendval2']) && !empty($_POST['sendval3']) && 
    !empty($_POST['sendval4']) && !empty($_POST['sendval5']) && !empty($_POST['sendval6']) && 
    !empty($_POST['sendval7']) && !empty($_POST['sendval8']) && !empty($_POST['sendval9']) && 
    !empty($_POST['sendval10']) && !empty($_POST['sendval11']) && !empty($_POST['sendval12']) && 
    !empty($_POST['sendval13']) && !empty($_POST['sendval14'])) {
    
    // Get values from POST request
    $val1 = $_POST['sendval1'];
    $val2 = $_POST['sendval2'];
    $val3 = $_POST['sendval3'];
    $val4 = $_POST['sendval4'];
    $val5 = $_POST['sendval5'];
    $val6 = $_POST['sendval6'];
    $val7 = $_POST['sendval7'];
    $val8 = $_POST['sendval8'];
    $val9 = $_POST['sendval9'];
    $val10 = $_POST['sendval10'];
    $val11 = $_POST['sendval11'];
    $val12 = $_POST['sendval12'];
    $val13 = $_POST['sendval13'];
    $val14 = $_POST['sendval14'];

    // Prepare and execute the first insert statement
    $sql1 = "INSERT INTO field_info (temp, hum, soil_mois, rain, flow_rate, volume, field_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
    $stmt1 = $conn->prepare($sql1);
    
    if ($stmt1) {
        $stmt1->bind_param("sssssss", $val1, $val2, $val3, $val4, $val5, $val6, $val7);
        if ($stmt1->execute()) {
            echo "First set of values inserted into field_info table.<br>";
        } else {
            echo "Error executing the first insert: " . $stmt1->error . "<br>";
        }
        $stmt1->close();
    } else {
        echo "Error preparing the first statement: " . $conn->error . "<br>";
    }

    // Prepare and execute the second insert statement
    $sql2 = "INSERT INTO field_info (temp, hum, soil_mois, rain, flow_rate, volume, field_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
    $stmt2 = $conn->prepare($sql2);
    
    if ($stmt2) {
        $stmt2->bind_param("sssssss", $val8, $val9, $val10, $val11, $val12, $val13, $val14);
        if ($stmt2->execute()) {
            echo "Second set of values inserted into field_info table.<br>";
        } else {
            echo "Error executing the second insert: " . $stmt2->error . "<br>";
        }
        $stmt2->close();
    } else {
        echo "Error preparing the second statement: " . $conn->error . "<br>";
    }
} else {
    echo "One or more sendval parameters are empty.<br>";
}

// Close the MySQL connection
$conn->close();
?>
