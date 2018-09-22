          const AWS = require('aws-sdk');
          let params = {
              Filters: [{
                  Name: "tag:aws:cloud9:environment",
                  Values: [
                      "5eef263604b042cf89e0276c9d7fc15c"
                  ]
              }]
          };
          let ec2 = new AWS.EC2();
          ec2.describeInstances(params, (err, data) => {
              if (err) {
                  console.log(err, err.stack); // an error occurred
                 
              }
              else {
                  console.log(data.Instances[0].SecurityGroups[0].GroupId);
                  let responseData = { Value: data.Instances[0].SecurityGroups[0].GroupId };
                  console.log(responseData);
              }

          });
          