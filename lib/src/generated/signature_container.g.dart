// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../model/attestation/signature_container.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignatureContainer _$SignatureContainerFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'SignatureContainer',
      json,
      ($checkedConvert) {
        final val = SignatureContainer(
          $checkedConvert('proposition',
              (v) => const PropositionConverter().fromJson(v as String)),
          $checkedConvert('proof',
              (v) => const SignatureConverter().fromJson(v as List<int>)),
        );
        return val;
      },
    );

Map<String, dynamic> _$SignatureContainerToJson(SignatureContainer instance) =>
    <String, dynamic>{
      'proposition': const PropositionConverter().toJson(instance.proposition),
      'proof': const SignatureConverter().toJson(instance.proof),
    };
