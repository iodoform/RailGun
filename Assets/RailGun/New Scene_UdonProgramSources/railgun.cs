/*
Copyright (c) 2024 iodoform
Released under the MIT license
https://opensource.org/licenses/mit-license.php
*/
using System.Collections.Generic;
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;
namespace IOD.RailGun
{
    public class railgun : UdonSharpBehaviour
    {
        [SerializeField]
        private Animator _animator;
        [SerializeField]
        private Material[] _materials;
        [SerializeField]
        [UdonSynced(UdonSyncMode.None)]
        private float _radius = 1;
        [SerializeField]
        private Transform _shotPoint;
        [UdonSynced(UdonSyncMode.None)]
        private Vector3 _shotPosition = Vector3.zero;
        [UdonSynced(UdonSyncMode.None)]
        private Vector3 _shotDirection = Vector3.zero;
        [SerializeField]
        private GameObject _trail;
        [SerializeField]
        private float _attenuationSpeed = 1;
        [SerializeField]
        private float _scale = 10;
        void Start()
        {
            _trail.SetActive(false);
        }
        public override void OnPlayerJoined(VRCPlayerApi player)
        {
            if (Networking.LocalPlayer == player)
            {
                _trail.SetActive(false);
                SetMaterialValues();
            }
        }
        void Update()
        {
            if (_trail.activeSelf)
            {
                var tmpScale = _trail.transform.localScale;
                var tmpZ = tmpScale.z;
                tmpScale -= Vector3.one * _attenuationSpeed;
                tmpScale.z = tmpZ;
                _trail.transform.localScale = tmpScale;
                if (tmpScale.x < 0)
                {
                    _trail.SetActive(false);
                }
            }
        }
        public override void OnPickupUseDown()
        {
            var player = Networking.LocalPlayer;
            Networking.SetOwner(player, gameObject);
            _shotDirection = transform.forward;
            _shotPosition = _shotPoint.position;
            RequestSerialization();
            SendCustomNetworkEvent(VRC.Udon.Common.Interfaces.NetworkEventTarget.All, "Trigger");
        }
        public void Trigger()
        {
            _animator.SetTrigger("trigger");
            SendCustomEventDelayedSeconds(nameof(Shot), 0.2f);
            _trail.transform.localScale = new Vector3(_radius, _radius, _radius) * _scale;
        }
        public void Shot()
        {
            _trail.SetActive(true);
            foreach (Material material in _materials)
            {
                material.SetFloat("_Radius", _radius);
                material.SetVector("_ShotDirection", transform.forward);
                material.SetVector("_ShotPoint", _shotPoint.position);
            }
        }

        private void SetMaterialValues()
        {
            foreach (Material material in _materials)
            {
                material.SetFloat("_Radius", _radius);
                material.SetVector("_ShotDirection", _shotDirection);
                material.SetVector("_ShotPoint", _shotPosition);
            }
        }
    }
}
