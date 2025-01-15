<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "irrigation";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Query automatic_control for last automatic_status values of field_id 'f1' and 'f2'
$sql1 = "SELECT automatic_status FROM automatic_control WHERE field_id = 'f1' ORDER BY id DESC LIMIT 1";
$sql2 = "SELECT automatic_status FROM automatic_control WHERE field_id = 'f2' ORDER BY id DESC LIMIT 1";

$result1 = $conn->query($sql1);
$result2 = $conn->query($sql2);

$auto_status_f1 = $result1->num_rows > 0 ? $result1->fetch_assoc()['automatic_status'] : '';
$auto_status_f2 = $result2->num_rows > 0 ? $result2->fetch_assoc()['automatic_status'] : '';

// Query manual_control for last manual_status values of field_id 'f1' and 'f2'
$sql3 = "SELECT manual_status FROM manual_control WHERE field_id = 'f1' ORDER BY id DESC LIMIT 1";
$sql4 = "SELECT manual_status FROM manual_control WHERE field_id = 'f2' ORDER BY id DESC LIMIT 1";

$result3 = $conn->query($sql3);
$result4 = $conn->query($sql4);

$manual_status_f1 = $result3->num_rows > 0 ? $result3->fetch_assoc()['manual_status'] : '';
$manual_status_f2 = $result4->num_rows > 0 ? $result4->fetch_assoc()['manual_status'] : '';

// Query field_info for last soil_mois values of field_id 'f1' and 'f2'
$sql5 = "SELECT soil_mois FROM field_info WHERE field_id = 'f1' ORDER BY id DESC LIMIT 1";
$sql6 = "SELECT soil_mois FROM field_info WHERE field_id = 'f2' ORDER BY id DESC LIMIT 1";

$result5 = $conn->query($sql5);
$result6 = $conn->query($sql6);

$soil_mois_f1 = $result5->num_rows > 0 ? $result5->fetch_assoc()['soil_mois'] : '';
$soil_mois_f2 = $result6->num_rows > 0 ? $result6->fetch_assoc()['soil_mois'] : '';

$conn->close();

// Return JSON response
echo json_encode([
    "auto_status_f1" => $auto_status_f1,
    "auto_status_f2" => $auto_status_f2,
    "manual_status_f1" => $manual_status_f1,
    "manual_status_f2" => $manual_status_f2,
    "soil_mois_f1" => $soil_mois_f1,
    "soil_mois_f2" => $soil_mois_f2
]);
?>
