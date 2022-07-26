# RMIT University Vietnam
#   Course: COSC2767 Systems Deployment and Operations
#   Semester: 2022B
#   Assessment: Assignment 1
#   Author: Nguyen Cuong Anh Minh
#   ID: 3931605
#   Created date: 26/07/2022
#   Last modified: 26/07/2022
#   Acknowledgement: to Ania Kubów for the using of her content: https://www.youtube.com/watch?v=-D6oTPA4vXc and images from google.

# cp bash file to root folder
cp -a bash/. ~

# Install JDK 11 and "y" for the asking
sudo amazon-linux-extras install java-openjdk11 -y

# Go to "opt" folder
cd /opt

# Install maven
wget https://dlcdn.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz

# Unzip maven zip folder
tar -xvzf apache-maven-3.8.6-bin.tar.gz

# Change the folder name to be "maven"
mv apache-maven-3.8.6 maven

# Go back to the root folder
cd ~

# Edit the .bash_profile to have JAVA_HOME, M2_HOME and M2 env
# I insert at line 9,10,11
#https://www.unix.com/shell-programming-and-scripting/100708-modify-specific-line-text-file.html
sed -i '9 i JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.13.0.8-1.amzn2.0.3.x86_64' .bash_profile
sed -i '10 i M2_HOME=/opt/maven' .bash_profile
sed -i '11 i M2=/opt/maven/bin' .bash_profile

# delete the 13rd line in bash profile, which is the PATH line.
# https://www.geeksforgeeks.org/sed-command-in-linux-unix-with-examples/
sed '13d' .bash_profile

# Edit the .bash_profile to have PATH variable
# I insert at line 13
sed -i '13 i PATH=$PATH:$HOME/bin:$JAVA_HOME:$M2_HOME:$M2' .bash_profile

# Reset the bash_profile to apply new changes
source .bash_profile

# Go top "opt" folder
cd /opt

# Install tomcat
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.65/bin/apache-tomcat-9.0.65.tar.gz

# Unzip tomcat zip folder
tar -xvzf apache-tomcat-9.0.65.tar.gz

# Change the folder name to be "tomcat"
mv apache-tomcat-9.0.65 tomcat

# comment line 21,22 in /opt/tomcat/webapps/host-manager/META-INF/context.xml
# which is the <Valve/> to disable tomcat only serve local
sed -i '21s/^/<!-- /; 22s/$/ -->/' /opt/tomcat/webapps/host-manager/META-INF/context.xml

# comment line 21,22 in /opt/tomcat/webapps/manager/META-INF/context.xml
# which is the <Valve/> to disable tomcat only serve local
sed -i '21s/^/<!-- /; 22s/$/ -->/' /opt/tomcat/webapps/manager/META-INF/context.xml

# Edit the tomcat-users.xml to have an admin user with required actions
# I insert at line 42,43,44,45,46,47
sed -i '42 i <role rolename="admin-gui"/>' /opt/tomcat/conf/tomcat-users.xml
sed -i '43 i <role rolename="manager-gui"/>' /opt/tomcat/conf/tomcat-users.xml
sed -i '44 i <role rolename="manager-script"/>' /opt/tomcat/conf/tomcat-users.xml
sed -i '45 i <role rolename="manager-jmx"/>' /opt/tomcat/conf/tomcat-users.xml
sed -i '46 i <role rolename="manager-status"/>' /opt/tomcat/conf/tomcat-users.xml
sed -i '47 i <user username="admin" password="s3cret" roles="admin-gui,manager-gui, manager-script, manager-jmx, manager-status"/>' /opt/tomcat/conf/tomcat-users.xml

# Create a symbolic link in system bin to call tomcatup and tomcatdown
ln -s /opt/tomcat/bin/startup.sh /usr/local/bin/tomcatup
ln -s /opt/tomcat/bin/shutdown.sh /usr/local/bin/tomcatdown

# Go back to root folder
cd ~

# Generate my simple web application
mvn archetype:generate -DgroupId=vn.edu.rmit -DartifactId=mySimpleProfile -DarchetypeArtifactId=maven-archetype-webapp -DinteractiveMode=false

# Remove the default index.jsp file
rm -rf mySimpleProfile/src/main/webapp/index.jsp

# Copy all the src file in my github repo to this maven project
cp -a myProfile/COSC2767_Assignment1_BashScript_AWS_s3931605/src/. mySimpleProfile/src/main/webapp/

# Go to mySimpleProfile folder
cd mySimpleProfile/

# Build the web app package using maven
mvn package

# Copy the war file to Tomcat webapps folder to host
cp /root/mySimpleProfile/target/mySimpleProfile.war /opt/tomcat/webapps/

# Tell the tomcat server to go on production
tomcatup

# # Copy everything inside the folder to a new destination
# # https://stackoverflow.com/questions/14922562/how-do-i-copy-folder-with-files-to-another-folder-in-unix-linux
# cp -a path_to_source/. path_to_destination/

# #Cmt specific lines
# sed -i '2,4 s/^/#/' bla.conf

# # Cmt xml for Tomcat
# sed '10s/^/<!-- /; 11s/$/ -->/' tomcatConfig.txt