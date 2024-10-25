using UnityEngine;
using UnityEditor;
using System;
using System.Collections.Generic;

namespace LcLGame.PRTGI
{
//标记序列化二进制

    [Serializable, PreferBinarySerialization]
    [CreateAssetMenu(fileName = "ProbeVolumeData", menuName = "LcL/ProbeVolumeData")]
    public class ProbeData : ScriptableObject
    {
        [SerializeField] public Vector3 volumePosition;

        [SerializeField] public List<Surfel> surfelBuffer = new List<Surfel>();

        public void StorageSurfelData(ProbeVolume volume)
        {
            surfelBuffer.Clear();
            foreach (var probe in volume.Probes)
            {
                foreach (var surfel in probe.SurfelBuffer)
                {
                    surfelBuffer.Add(surfel);
                }
            }

            volumePosition = volume.gameObject.transform.position;
            EditorUtility.SetDirty(this);
            AssetDatabase.SaveAssets();
        }

        // load surfel data from storage
        public void TryLoadSurfelData(ProbeVolume volume)
        {
            int probeNum = volume.Probes.Count;
            bool dataDirty = surfelBuffer.Count != probeNum * ProbeVolume.SampleCount;
            bool posDirty = volume.gameObject.transform.position != volumePosition;
            if (posDirty || dataDirty)
            {
                Debug.Log("探针组数据需要重新捕获");
                return;
            }

            int surfelIndex = 0;
            foreach (var probe in volume.Probes)
            {
                for (int i = 0; i < ProbeVolume.SampleCount; i++)
                {
                    probe.SurfelBuffer[i] = surfelBuffer[surfelIndex++];
                }

                probe.surfels.SetData(probe.SurfelBuffer);
            }
        }
    }
}
