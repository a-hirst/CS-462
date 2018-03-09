angular.module('temperatures', [])
.controller('MainCtrl', [
  '$scope','$http',
  function($scope,$http){
    $scope.page = "temps";
    $scope.temperatures = [];
    $scope.eci = "5tZG7V8TrdjwdVtsgLXqx5";


    var tempsURL = 'http://localhost:8080/sky/cloud/'+$scope.eci+'/temperature_store/temperatures';
    $scope.getAll = function() {
      return $http.get(tempsURL).success(function(data){
        console.log(data);
        angular.copy(data.reverse(), $scope.temperatures);

        if($scope.temperatures.length > 0) {
          $scope.currTemp = $scope.temperatures[0];
        }
        $scope.getViolations();
      });
    };

    var violationsURL = 'http://localhost:8080/sky/cloud/'+$scope.eci+'/temperature_store/threshold_violations';
    $scope.getViolations = function() {
      return $http.get(violationsURL).success(function(data){

        $scope.temperatures.forEach(function(item) {

          item.violation = data.findIndex(function (item2) {
            return item2.timestamp == item.timestamp;
          }) > -1;
          item.time = new Date(item.timestamp).toString();
        });

      });
    };

    $scope.getAll();

  var profileDataURL = 'http://localhost:8080/sky/cloud/'+$scope.eci+'/sensor_profile/profile_info';
    $scope.changePage = function(page) {
      $scope.page = page;
      console.log("page: " + page);

      if (page == "updateProfile") {
        console.log('1');
        return $scope.loadProfileData();
      }
    }

    $scope.loadProfileData = function() {
      return $http.get(profileDataURL).success(function(data){
          console.log(data);
          $scope.sensorName = angular.copy(data.sensorName);
          $scope.sensorLoc = angular.copy(data.sensorLocation);
          $scope.smsNum = angular.copy(data.smsNumber);
          $scope.tempThreshold = angular.copy(data.temperatureThreshold);
        });
    }

    var updateURL = 'http://localhost:8080/sky/event/'+$scope.eci+'/none/sensor/profile_updated';
    $scope.updateProfile = function(name, loc, sms, temp) {
        console.log(temp, sms, loc, name);

      var updateDataURL = updateURL + "?";
      if(name) 
        updateDataURL += "sensorName=" + name + "&";
      if(loc)
        updateDataURL += "sensorLocation=" + $scope.loc + "&";
      if(sms)
        updateDataURL += "smsNum=" + encodeURIComponent(sms) + "&";
      if(temp)
        updateDataURL += "tempThreshold=" + temp;

      return $http.post(updateDataURL).success(function(data){
      });
    }
   
  }
]);
