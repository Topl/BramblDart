import 'package:docker_process/docker_process.dart';

Future<DockerProcess> startBifrost(
    {required String name,
    required String version,
    String imageName = 'toplprotocol/bifrost',
    String? network,
    int bifrostRpcPort = 9084,
    int bifrostHttpPort = 9085,
    bool? cleanup}) async {
  return await DockerProcess.start(
      name: name,
      image: '$imageName:$version',
      dockerCommand: 'run',
      network: network,
      ports: ['$bifrostHttpPort:9085', '$bifrostRpcPort:9084'],
      cleanup: cleanup,
      readySignal: (line) {
        return line.contains('HTTP server bound to');
      });
}
