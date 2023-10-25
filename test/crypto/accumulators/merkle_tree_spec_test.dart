import 'package:brambldart/src/common/functional/either.dart';
import 'package:brambldart/src/crypto/accumulators/accumulators.dart';
import 'package:brambldart/src/crypto/accumulators/merkle/merkle_tree.dart';
import 'package:brambldart/src/crypto/accumulators/merkle/node.dart';
import 'package:brambldart/src/crypto/hash/digest/digest.dart';
import 'package:brambldart/src/crypto/hash/hash.dart';
import 'package:collection/collection.dart';
import 'package:test/test.dart';

import '../helpers/generators.dart';

void main() {
  final hf = blake2b256;
  const leafSize = 32;

  group('Merkle Tree Spec', () {
    test('Proof generation by element', () {
      for (var n = 1; n <= 15; n++) {
        final d = List.generate(n, (_) => LeafData(Generators.genByteArrayOfSize(leafSize)));
        final leafs = d.map((data) => Leaf(data: data, h: hf));
        final tree = MerkleTree.fromLeafs(d, hf);
        final treeRootHash = tree.rootHash;

        for (final l in leafs) {
          final proof = tree.proofByElement(l).getOrThrow(Exception("Proof is invalid"));

          expect(proof.leafData, l.data);

          expect(proof.valid(treeRootHash), isTrue);
        }
      }
    });

    test('Proof generation by index', () {
      for (var n = 1; n <= 15; n++) {
        final d = List.generate(n, (_) => LeafData(Generators.genByteArrayOfSize(leafSize)));
        final tree = MerkleTree.fromLeafs(d, hf);

        for (var i = 0; i < n; i++) {
          final proof = tree.proofByIndex(i).getOrThrow(Exception("Proof is invalid"));

          expect(const ListEquality().equals(proof.leafData.value, d[i].value), isTrue);
          expect(proof.valid(tree.rootHash), isTrue);
        }

        for (var i = n; i < n + 100; i++) {
          final proof = tree.proofByIndex(i);
          expect(proof is None, true);
        }

        for (var i = -(n + 100); i < 0; i++) {
          final proof = tree.proofByIndex(i);
          expect(proof is None, true);
        }
      }
    });

    test('Tree creation from 0 elements', () {
      final tree = MerkleTree.fromLeafs([], hf);
      expect(tree.rootHash, Digest.empty());
    });

    test('Tree creation from 1 element', () {
      for (var n = 1; n <= 15; n++) {
        final d = Generators.getRandomBytes();
        if (d.isNotEmpty) {
          final tree = MerkleTree.fromLeafs([LeafData(d)], hf);
          final lfp = hf.hashWithPrefix(MerkleTree.leafPrefix, [d]);
          final inp = hf.hashWithPrefix(MerkleTree.internalNodePrefix, [lfp.bytes]);

          expect(tree.rootHash, inp);
        }
      }
    });

    test('Tree creation from 5 elements', () {
      for (var n = 1; n <= 15; n++) {
        final d = Generators.getRandomBytes();
        if (d.isNotEmpty) {
          final leafs = List.generate(5, (_) => LeafData(d));
          final tree = MerkleTree.fromLeafs(leafs, hf);
          final h0x = hf.hashWithPrefix(MerkleTree.leafPrefix, [d]);
          final h10 = hf.hashWithPrefix(MerkleTree.internalNodePrefix, [h0x.bytes, h0x.bytes]);
          final h11 = h10;
          final h12 = hf.hashWithPrefix(MerkleTree.internalNodePrefix, [h0x.bytes]);
          final h20 = hf.hashWithPrefix(MerkleTree.internalNodePrefix, [h10.bytes, h11.bytes]);
          final h21 = hf.hashWithPrefix(MerkleTree.internalNodePrefix, [h12.bytes]);
          final h30 = hf.hashWithPrefix(MerkleTree.internalNodePrefix, [h20.bytes, h21.bytes]);
          expect(tree.rootHash, h30);
        }
      }
    });

    test('Tree creation from 2 elements', () {
      for (var n = 1; n <= 15; n++) {
        final d1 = Generators.getRandomBytes();
        final d2 = Generators.getRandomBytes();
        final leafs = [LeafData(d1), LeafData(d2)];
        final tree = MerkleTree.fromLeafs(leafs, hf);
        final h0x1 = hf.hashWithPrefix(MerkleTree.leafPrefix, [d1]);
        final h0x2 = hf.hashWithPrefix(MerkleTree.leafPrefix, [d2]);
        final h10 = hf.hashWithPrefix(MerkleTree.internalNodePrefix, [h0x1.bytes, h0x2.bytes]);

        expect(tree.rootHash, h10);
      }
    });

    test('Tree creation from a lot of elements', () {
      for (var n = 1; n <= 15; n++) {
        final d = List.generate(n * 3, (_) => Generators.getRandomBytes());
        if (d.isNotEmpty) {
          final leafs = d.map((a) => LeafData(a)).toList();
          final tree = MerkleTree.fromLeafs(leafs, hf);

          expect(tree.rootHash, isNotNull);
        }
      }
    });
  });
}
